## PoolManager Autoload
##
## 責務:
## - オブジェクトプールの一元管理（敵・弾丸・経験値オーブ）
## - シーンパス別プール管理（型混在防止）
## - 実体の親ノード管理（Autoload直下ではなくworld_nodeへreparent）
## - LRU方式でプール上限管理
##
## 重要:
## - 純粋Autoloadとして使用（シーンに配置しない）
## - 敵はシーンパス別Dictionaryで管理（basic/strongの混在回避）
## - 生成したノードはworld_nodeへreparentする（Autoload階層問題回避）
## - 返却時は衝突を無効化してからreparentする
extends Node

## デバッグコンテキスト名
const DEBUG_CONTEXT: String = "PoolManager"

## 敵プールの最大サイズ（シーンパス別）
const MAX_ENEMY_POOL_SIZE: int = 200
## 弾丸プールの最大サイズ
const MAX_PROJECTILE_POOL_SIZE: int = 500
## 経験値オーブプールの最大サイズ
const MAX_EXP_ORB_POOL_SIZE: int = 200

## 敵のプール（シーンパス別）: {scene_path: Array[Node]}
var enemy_pools: Dictionary = {}
## アクティブな敵（シーンパス別）: {scene_path: Array[Node]}
var active_enemies: Dictionary = {}

## 弾丸のプール
var projectile_pool: Array[Node] = []
## アクティブな弾丸
var active_projectiles: Array[Node] = []

## 経験値オーブのプール
var exp_orb_pool: Array[Node] = []
## アクティブな経験値オーブ
var active_exp_orbs: Array[Node] = []

## 敵弾のプール
const MAX_ENEMY_PROJECTILE_POOL_SIZE: int = 100
var enemy_projectile_pool: Array[Node] = []
## アクティブな敵弾
var active_enemy_projectiles: Array[Node] = []

## 実体を配置する親ノード（GameSceneから設定される）
var world_node: Node = null


func _ready() -> void:
	# Autoload初期化時は何もしない（プールは遅延生成）
	pass


## 実体を配置する親ノードを設定する
##
## GameScene._ready()から呼ばれる。
## 以降、spawn系関数で生成したノードはこのworld_nodeの子として配置される。
##
## @param node: 親ノード（通常はGameScene内のWorldNode）
func set_world_node(node: Node) -> void:
	if node == null:
		push_error("PoolManager.set_world_node: nodeがnullです")
		return

	world_node = node


## 敵をスポーンする
##
## シーンパス別プールから取得、または新規作成。
## プール上限到達時はnullを返す。
##
## @param scene_path: 敵シーンのパス（例: "res://scenes/enemies/basic_enemy.tscn"）
## @param position: スポーン位置
## @return: 生成された敵ノード（失敗時はnull）
func spawn_enemy(scene_path: String, position: Vector2) -> Node:
	# シーンパス別プールの存在確認・初期化
	_ensure_enemy_pool(scene_path)

	var enemy: Node = null

	# プールから取得
	if enemy_pools[scene_path].is_empty():
		# プールが空なら新規作成（上限チェック）
		var active_count: int = active_enemies[scene_path].size()
		if active_count >= MAX_ENEMY_POOL_SIZE:
			push_warning("PoolManager.spawn_enemy: 敵プール上限到達 path=%s count=%d" % [scene_path, active_count])
			return null

		# 新規作成
		if not ResourceLoader.exists(scene_path):
			push_error("PoolManager.spawn_enemy: シーンが存在しません path=%s" % scene_path)
			return null

		var scene: PackedScene = load(scene_path)
		if scene == null:
			push_error("PoolManager.spawn_enemy: シーンのロードに失敗 path=%s" % scene_path)
			return null

		enemy = scene.instantiate()
		enemy.set_meta("pool_scene_path", scene_path)  # 返却時の識別用
		add_child(enemy)  # 一時的にAutoloadの子として追加
	else:
		# プールから取り出し
		enemy = enemy_pools[scene_path].pop_back()

	if enemy == null:
		push_error("PoolManager.spawn_enemy: 敵の取得に失敗")
		return null

	# world_nodeへreparent（重要: Autoload階層から脱出）
	if world_node != null:
		enemy.reparent(world_node)
	else:
		push_warning("PoolManager.spawn_enemy: world_nodeが未設定です")

	# 敵の初期化
	enemy.global_position = position
	enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
	enemy.visible = true

	# 衝突有効化
	if enemy is CharacterBody2D or enemy is RigidBody2D or enemy is Area2D:
		enemy.collision_layer = 2  # 敵レイヤー
		enemy.collision_mask = 1 | 4  # プレイヤー | 弾丸

	# 敵の状態リセット（reset()メソッドがあれば呼び出す）
	# 注: initialize()はSpawner側で呼ぶため、ここでは呼ばない（二重初期化防止）
	if enemy.has_method("reset"):
		enemy.reset()

	# アクティブリストに追加
	active_enemies[scene_path].append(enemy)

	return enemy


## 敵をプールに返却する
##
## 衝突を無効化し、PoolManagerの子に戻す。
##
## @param enemy: 返却する敵ノード
func return_enemy(enemy: Node) -> void:
	if enemy == null:
		push_warning("PoolManager.return_enemy: enemyがnullです")
		return

	# シーンパスを取得
	var scene_path: String = enemy.get_meta("pool_scene_path", "")
	if scene_path == "":
		push_error("PoolManager.return_enemy: 敵のシーンパスが不明です")
		return

	# 非表示・停止
	enemy.visible = false
	enemy.process_mode = Node.PROCESS_MODE_DISABLED

	# 衝突無効化（重要: 返却前に当たり判定を切る）
	# set_deferredで物理演算との競合を回避
	if enemy is CharacterBody2D or enemy is RigidBody2D or enemy is Area2D:
		enemy.set_deferred("collision_layer", 0)
		enemy.set_deferred("collision_mask", 0)

	# PoolManagerの子に戻す（deferredで実行）
	enemy.call_deferred("reparent", self)

	# アクティブリストから削除、プールに追加
	if scene_path in active_enemies:
		active_enemies[scene_path].erase(enemy)
	if scene_path in enemy_pools:
		enemy_pools[scene_path].append(enemy)


## 弾丸をスポーンする
##
## プールから取得、または新規作成。
##
## @param position: スポーン位置
## @param direction: 弾丸の方向（正規化済み）
## @param damage: ダメージ量
## @return: 生成された弾丸ノード（失敗時はnull）
func spawn_projectile(position: Vector2, direction: Vector2, damage: int) -> Node:
	var projectile: Node = null

	# プールから取得
	if projectile_pool.is_empty():
		# プールが空なら新規作成（上限チェック）
		if active_projectiles.size() >= MAX_PROJECTILE_POOL_SIZE:
			push_warning("PoolManager.spawn_projectile: 弾丸プール上限到達 count=%d" % active_projectiles.size())
			return null

		# 新規作成
		var scene_path: String = "res://scenes/weapons/projectile.tscn"
		if not ResourceLoader.exists(scene_path):
			push_error("PoolManager.spawn_projectile: 弾丸シーンが存在しません")
			return null

		var scene: PackedScene = load(scene_path)
		if scene == null:
			push_error("PoolManager.spawn_projectile: 弾丸シーンのロードに失敗")
			return null

		projectile = scene.instantiate()
		add_child(projectile)  # 一時的にAutoloadの子として追加
	else:
		# プールから取り出し
		projectile = projectile_pool.pop_back()

	if projectile == null:
		push_error("PoolManager.spawn_projectile: 弾丸の取得に失敗")
		return null

	# world_nodeへreparent
	if world_node != null:
		projectile.reparent(world_node)

	# 弾丸の初期化（initializeメソッドを呼び出す）
	if projectile.has_method("initialize"):
		projectile.initialize(position, direction, damage)
	else:
		# initializeメソッドがない場合は直接設定
		projectile.global_position = position
		if "direction" in projectile:
			projectile.direction = direction
		if "damage" in projectile:
			projectile.damage = damage

	projectile.process_mode = Node.PROCESS_MODE_PAUSABLE
	projectile.visible = true

	# 衝突を有効化（Area2Dの場合）
	if projectile is Area2D:
		projectile.set_deferred("monitoring", true)
		projectile.set_deferred("monitorable", true)
		# CollisionShape2Dも有効化
		var collision_shape = projectile.get_node_or_null("CollisionShape2D")
		if collision_shape != null:
			collision_shape.set_deferred("disabled", false)

	# アクティブリストに追加
	active_projectiles.append(projectile)

	return projectile


## 弾丸をプールに返却する
##
## @param projectile: 返却する弾丸ノード
func return_projectile(projectile: Node) -> void:
	if projectile == null:
		push_warning("PoolManager.return_projectile: projectileがnullです")
		return

	# 非表示・停止
	projectile.visible = false
	projectile.process_mode = Node.PROCESS_MODE_DISABLED

	# 衝突無効化（Area2Dの場合）
	if projectile is Area2D:
		projectile.set_deferred("monitoring", false)
		projectile.set_deferred("monitorable", false)
		# CollisionShape2Dも無効化
		var collision_shape = projectile.get_node_or_null("CollisionShape2D")
		if collision_shape != null:
			collision_shape.set_deferred("disabled", true)

	# PoolManagerの子に戻す（deferredで実行）
	projectile.call_deferred("reparent", self)

	# アクティブリストから削除、プールに追加
	active_projectiles.erase(projectile)
	projectile_pool.append(projectile)


## 経験値オーブをスポーンする
##
## プールから取得、または新規作成。
## 上限到達時は最も古いオーブを返却して再利用（LRU方式）。
##
## @param position: スポーン位置
## @param exp_value: 経験値量
## @return: 生成された経験値オーブノード（失敗時はnull）
func spawn_exp_orb(position: Vector2, exp_value: int) -> Node:
	DebugConfig.log_debug(DEBUG_CONTEXT, "spawn_exp_orb() called - position: %v, exp_value: %d" % [position, exp_value])
	var orb: Node = null

	# プールから取得
	if exp_orb_pool.is_empty():
		DebugConfig.log_debug(DEBUG_CONTEXT, "exp_orb_pool is empty - creating new or reusing")
		# プールが空なら新規作成（上限チェック）
		if active_exp_orbs.size() >= MAX_EXP_ORB_POOL_SIZE:
			# 上限到達時は最も古いオーブを返却して再利用（LRU方式）
			push_warning("PoolManager.spawn_exp_orb: 経験値オーブプール上限到達、LRU方式で再利用")
			orb = active_exp_orbs[0]
			return_exp_orb(orb)
			orb = exp_orb_pool.pop_back()
		else:
			# 新規作成
			DebugConfig.log_debug(DEBUG_CONTEXT, "Creating new ExpOrb instance")
			var scene_path: String = "res://scenes/items/exp_orb.tscn"
			if not ResourceLoader.exists(scene_path):
				push_error("PoolManager.spawn_exp_orb: 経験値オーブシーンが存在しません")
				return null

			var scene: PackedScene = load(scene_path)
			if scene == null:
				push_error("PoolManager.spawn_exp_orb: 経験値オーブシーンのロードに失敗")
				return null

			orb = scene.instantiate()
			DebugConfig.log_trace(DEBUG_CONTEXT, "ExpOrb instantiated - name: %s" % orb.name)
			add_child(orb)  # 一時的にAutoloadの子として追加
			DebugConfig.log_trace(DEBUG_CONTEXT, "ExpOrb added as child of PoolManager")
	else:
		# プールから取り出し
		DebugConfig.log_debug(DEBUG_CONTEXT, "Reusing ExpOrb from pool - pool_size: %d" % exp_orb_pool.size())
		orb = exp_orb_pool.pop_back()

	if orb == null:
		push_error("PoolManager.spawn_exp_orb: 経験値オーブの取得に失敗")
		return null

	# world_nodeへreparent
	if world_node != null:
		DebugConfig.log_trace(DEBUG_CONTEXT, "Reparenting ExpOrb to world_node")
		orb.reparent(world_node)
	else:
		DebugConfig.log_critical(DEBUG_CONTEXT, "ERROR: world_node is null!")

	# デバッグ: スクリプト確認
	DebugConfig.log_trace(DEBUG_CONTEXT, "orb script: %s, has initialize: %s, class: %s" % [orb.get_script(), orb.has_method("initialize"), orb.get_class()])

	# 経験値オーブの初期化（deferredで呼び出して物理エンジンとの競合を回避）
	if orb.has_method("initialize"):
		DebugConfig.log_debug(DEBUG_CONTEXT, "Calling ExpOrb.initialize() via call_deferred")
		# call_deferredでinitializeを呼び出す（reparent後の物理フレームと競合しないように）
		orb.call_deferred("initialize", position, exp_value)
	else:
		# initializeメソッドがない場合は直接設定
		push_warning("PoolManager.spawn_exp_orb: ExpOrbにinitializeメソッドがありません")
		DebugConfig.log_critical(DEBUG_CONTEXT, "WARNING: ExpOrb doesn't have initialize method - setting properties directly")
		orb.global_position = position
		if "exp_value" in orb:
			orb.exp_value = exp_value
		orb.visible = true
		orb.process_mode = Node.PROCESS_MODE_PAUSABLE

	# アクティブリストに追加
	active_exp_orbs.append(orb)
	DebugConfig.log_trace(DEBUG_CONTEXT, "ExpOrb added to active list - active_count: %d" % active_exp_orbs.size())

	return orb


## 経験値オーブをプールに返却する
##
## @param orb: 返却する経験値オーブノード
func return_exp_orb(orb: Node) -> void:
	if orb == null:
		push_warning("PoolManager.return_exp_orb: orbがnullです")
		return

	# 非表示・停止
	orb.visible = false
	orb.process_mode = Node.PROCESS_MODE_DISABLED

	# reset()メソッドがあれば呼び出す（ただし物理クエリ中の可能性があるため、deferredで実行）
	if orb.has_method("reset"):
		orb.call_deferred("reset")

	# PoolManagerの子に戻す（deferredで実行）
	orb.call_deferred("reparent", self)

	# アクティブリストから削除、プールに追加
	active_exp_orbs.erase(orb)
	exp_orb_pool.append(orb)


## 敵弾をスポーンする
##
## @param position: スポーン位置
## @param direction: 弾丸の方向
## @param damage: ダメージ量
## @return: 生成された敵弾ノード
func spawn_enemy_projectile(position: Vector2, direction: Vector2, damage: int) -> Node:
	var projectile: Node = null

	if enemy_projectile_pool.is_empty():
		if active_enemy_projectiles.size() >= MAX_ENEMY_PROJECTILE_POOL_SIZE:
			push_warning("PoolManager: 敵弾プール上限到達 count=%d" % active_enemy_projectiles.size())
			return null

		var scene_path: String = "res://scenes/weapons/enemy_projectile.tscn"
		if not ResourceLoader.exists(scene_path):
			push_error("PoolManager: 敵弾シーンが存在しません")
			return null

		var scene: PackedScene = load(scene_path)
		if scene == null:
			push_error("PoolManager: 敵弾シーンのロードに失敗")
			return null

		projectile = scene.instantiate()
		add_child(projectile)
	else:
		projectile = enemy_projectile_pool.pop_back()

	if projectile == null:
		push_error("PoolManager: 敵弾の取得に失敗")
		return null

	if world_node != null:
		projectile.reparent(world_node)

	if projectile.has_method("initialize"):
		projectile.initialize(position, direction, damage)

	projectile.process_mode = Node.PROCESS_MODE_PAUSABLE
	projectile.visible = true

	active_enemy_projectiles.append(projectile)
	return projectile


## 敵弾をプールに返却する
##
## @param projectile: 返却する敵弾ノード
func return_enemy_projectile(projectile: Node) -> void:
	if projectile == null:
		push_warning("PoolManager.return_enemy_projectile: projectileがnullです")
		return

	projectile.visible = false
	projectile.process_mode = Node.PROCESS_MODE_DISABLED

	if projectile is Area2D:
		projectile.set_deferred("monitoring", false)
		projectile.set_deferred("monitorable", false)

	projectile.call_deferred("reparent", self)

	active_enemy_projectiles.erase(projectile)
	enemy_projectile_pool.append(projectile)


## 全てのアクティブオブジェクトをプールに返却する
##
## ゲーム終了時・ゲーム開始時に呼ばれる。
func clear_all_active() -> void:
	# 敵を全て返却
	for scene_path in active_enemies.keys():
		var enemies: Array = active_enemies[scene_path].duplicate()  # duplicate()で配列をコピー
		for enemy in enemies:
			return_enemy(enemy)

	# 弾丸を全て返却
	var projectiles: Array = active_projectiles.duplicate()
	for projectile in projectiles:
		return_projectile(projectile)

	# 経験値オーブを全て返却
	var orbs: Array = active_exp_orbs.duplicate()
	for orb in orbs:
		return_exp_orb(orb)

	# 敵弾を全て返却
	var enemy_projs: Array = active_enemy_projectiles.duplicate()
	for proj in enemy_projs:
		return_enemy_projectile(proj)


## 敵プールの存在確認・初期化（内部メソッド）
##
## シーンパス別プールが存在しない場合に初期化する。
##
## @param scene_path: 敵シーンのパス
func _ensure_enemy_pool(scene_path: String) -> void:
	if scene_path in enemy_pools:
		return  # 既に存在する

	# プールとアクティブリストを初期化
	enemy_pools[scene_path] = []
	active_enemies[scene_path] = []


## デバッグ用: 現在のプール状態を出力
func debug_print_status() -> void:
	print("=== PoolManager Status ===")
	print("Enemies:")
	for scene_path in enemy_pools.keys():
		var pool_count: int = enemy_pools[scene_path].size()
		var active_count: int = active_enemies[scene_path].size()
		print("  %s: pool=%d active=%d" % [scene_path, pool_count, active_count])
	print("Projectiles: pool=%d active=%d" % [projectile_pool.size(), active_projectiles.size()])
	print("EnemyProjectiles: pool=%d active=%d" % [enemy_projectile_pool.size(), active_enemy_projectiles.size()])
	print("ExpOrbs: pool=%d active=%d" % [exp_orb_pool.size(), active_exp_orbs.size()])
	print("========================")
