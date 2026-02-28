class_name WeaponInstance extends Node

## WeaponInstanceクラス
##
## 責務:
## - 武器の実体管理
## - 攻撃タイミング制御
## - 攻撃処理実行
##
## 重要:
## - owner_playerを直接参照（get_parent()禁止）
## - 武器方向はowner_player.velocity.normalized()

var weapon_data: Weapon = null
var current_level: int = 1
var owner_player: Node = null
var _attack_timer: float = 0.0

## Orbital武器用の衛星ノード
var _orbital_nodes: Array = []
var _orbital_angle: float = 0.0

## エフェクト用プリロード
const MUZZLE_FLASH_SCENE = preload("res://scenes/effects/muzzle_flash.tscn")

func _exit_tree() -> void:
	# Orbital衛星ノードをクリーンアップ（Playerの子として追加されているため手動で解放）
	for orbital in _orbital_nodes:
		if is_instance_valid(orbital):
			orbital.queue_free()
	_orbital_nodes.clear()


func initialize(weapon: Weapon, level: int, player: Node) -> void:
	if weapon == null:
		push_error("WeaponInstance.initialize: weapon is null")
		return
	if player == null:
		push_error("WeaponInstance.initialize: player is null")
		return

	weapon_data = weapon
	current_level = level
	owner_player = player

	# Orbital武器の場合は衛星を初期化
	if weapon.attack_type == Weapon.AttackType.ORBITAL:
		_initialize_orbital_nodes()

	# 範囲拡大を適用
	_apply_area_multiplier()

func _process(delta: float) -> void:
	if weapon_data == null or owner_player == null:
		return

	_attack_timer += delta

	# Orbital武器は常に更新が必要
	if weapon_data.attack_type == Weapon.AttackType.ORBITAL:
		_update_orbital(delta)

	if _can_attack():
		_attack()
		_attack_timer = 0.0

func level_up() -> void:
	current_level += 1
	print("武器レベルアップ: %s Lv.%d" % [weapon_data.weapon_name, current_level])

func _can_attack() -> bool:
	if weapon_data == null:
		return false
	return _attack_timer >= weapon_data.attack_interval

func _attack() -> void:
	if weapon_data == null or owner_player == null:
		return

	match weapon_data.attack_type:
		Weapon.AttackType.STRAIGHT_SHOT:
			_attack_straight_shot()
		Weapon.AttackType.AREA_BLAST:
			_attack_area_blast()
		Weapon.AttackType.HOMING_MISSILE:
			_attack_homing_missile()
		Weapon.AttackType.PENETRATING:
			_attack_penetrating()
		Weapon.AttackType.ORBITAL:
			_attack_orbital()
		Weapon.AttackType.CHAIN:
			_attack_chain()

func _attack_straight_shot() -> void:
	# 常に最も近い敵の方向に発射（ホーミングなし）
	var nearest_enemy = _find_nearest_enemy()
	var direction: Vector2

	if nearest_enemy != null:
		# 最寄りの敵方向に発射
		direction = (nearest_enemy.global_position - owner_player.global_position).normalized()
	else:
		# 敵がいない場合は進行方向、または右方向
		direction = owner_player.velocity.normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.RIGHT

	var damage = _calculate_damage()
	_spawn_projectile(owner_player.global_position, direction, damage, false)

	# マルチショット処理
	_apply_multishot(owner_player.global_position, direction, damage, false)

func _attack_area_blast() -> void:
	var damage = _calculate_damage()
	var angle_step = TAU / weapon_data.projectile_count  # 360度を等分

	for i in range(weapon_data.projectile_count):
		var angle = angle_step * i
		var direction = Vector2(cos(angle), sin(angle))
		_spawn_projectile(owner_player.global_position, direction, damage, false)

func _attack_homing_missile() -> void:
	var direction = owner_player.velocity.normalized()
	if direction == Vector2.ZERO:
		# 停止中は最寄りの敵方向に発射
		var nearest_enemy = _find_nearest_enemy()
		if nearest_enemy != null:
			direction = (nearest_enemy.global_position - owner_player.global_position).normalized()
		else:
			direction = Vector2.RIGHT

	var damage = _calculate_damage()
	_spawn_projectile(owner_player.global_position, direction, damage, true)

	# マルチショット処理
	_apply_multishot(owner_player.global_position, direction, damage, true)

func _calculate_damage() -> int:
	if weapon_data == null or owner_player == null:
		return 0

	# ベースダメージ計算（レベルに応じて10%ずつ増加）
	var base_damage = int(weapon_data.base_damage * (1.0 + (current_level - 1) * 0.1))

	var weapon_manager = owner_player.get_node_or_null("WeaponManager")
	if weapon_manager != null:
		# Double Damageパワーアップ適用
		var damage_multiplier = weapon_manager.get_damage_multiplier()
		base_damage = int(base_damage * damage_multiplier)

		# クリティカル判定
		if weapon_manager.critical_rate > 0.0:
			var roll = randf()
			if roll < weapon_manager.critical_rate:
				# クリティカルヒット！（ダメージ2倍）
				DebugConfig.log_debug("WeaponInstance", "クリティカルヒット! (確率: %.1f%%)" % [weapon_manager.critical_rate * 100])
				return base_damage * 2

	return base_damage

func _spawn_projectile(pos: Vector2, dir: Vector2, dmg: int, homing: bool, pierce: int = 0) -> void:
	if weapon_data == null:
		return

	var projectile = PoolManager.spawn_projectile(pos, dir, dmg)
	if projectile != null:
		projectile.speed = weapon_data.projectile_speed
		projectile.is_homing = homing
		projectile.attack_type = weapon_data.attack_type  # 武器タイプを設定
		projectile.pierce_count = pierce  # 貫通回数を設定

		# マズルフラッシュエフェクト（Orbital以外）
		if weapon_data.attack_type != Weapon.AttackType.ORBITAL:
			_spawn_muzzle_flash(pos)
			# 攻撃音再生
			AudioManager.play_sfx("shoot", -10.0)

func _find_nearest_enemy() -> Node:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var nearest: Node = null
	var min_distance: float = INF

	for enemy in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		var distance = owner_player.global_position.distance_squared_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = enemy

	return nearest


## 貫通攻撃（PENETRATING）
func _attack_penetrating() -> void:
	var direction = owner_player.velocity.normalized()
	if direction == Vector2.ZERO:
		var nearest_enemy = _find_nearest_enemy()
		if nearest_enemy != null:
			direction = (nearest_enemy.global_position - owner_player.global_position).normalized()
		else:
			direction = Vector2.RIGHT

	var damage = _calculate_damage()
	_spawn_projectile(owner_player.global_position, direction, damage, false, weapon_data.pierce_count)

	# マルチショット処理
	_apply_multishot(owner_player.global_position, direction, damage, false, weapon_data.pierce_count)


## 周回攻撃（ORBITAL）
func _attack_orbital() -> void:
	# Orbital武器は常時ダメージを与え続けるため、attack_intervalは0に設定される
	# 実際の攻撃処理は_update_orbital()内で行われる
	pass


## 連鎖攻撃（CHAIN）
func _attack_chain() -> void:
	var nearest_enemy = _find_nearest_enemy()
	if nearest_enemy == null:
		return

	var damage = _calculate_damage()
	AudioManager.play_sfx("shoot", -8.0)
	_deal_chain_damage(nearest_enemy, damage, weapon_data.chain_count, [])


## Orbital武器の衛星ノードを初期化
func _initialize_orbital_nodes() -> void:
	# 既存の衛星をクリア
	for node in _orbital_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_orbital_nodes.clear()

	# 新しい衛星を生成（Area2Dベース）
	for i in range(weapon_data.orbital_count):
		var orbital = Area2D.new()
		orbital.name = "Orbital_%d" % i

		# コリジョン設定
		orbital.collision_layer = 0
		orbital.collision_mask = 2  # Layer 2 (敵)

		# コリジョンシェイプを追加
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 8.0  # 衛星のサイズ
		shape.shape = circle
		orbital.add_child(shape)

		# ビジュアル（ColorRect）を追加
		var visual = ColorRect.new()
		visual.size = Vector2(16, 16)
		visual.position = Vector2(-8, -8)  # 中心に配置
		visual.color = Color.CYAN
		orbital.add_child(visual)

		# シグナル接続
		orbital.body_entered.connect(_on_orbital_hit.bind(orbital))

		# プレイヤーの子として追加
		owner_player.add_child(orbital)
		_orbital_nodes.append(orbital)


## Orbital武器の位置更新
func _update_orbital(delta: float) -> void:
	if _orbital_nodes.is_empty():
		return

	_orbital_angle += weapon_data.orbital_speed * delta

	# 範囲拡大を考慮した半径
	var weapon_manager = owner_player.get_node_or_null("WeaponManager")
	var effective_radius = weapon_data.orbital_radius
	if weapon_manager != null:
		effective_radius *= weapon_manager.area_multiplier

	for i in range(_orbital_nodes.size()):
		var orbital = _orbital_nodes[i]
		if not is_instance_valid(orbital):
			continue

		# 各衛星の角度を計算（等間隔に配置）
		var angle_offset = (TAU / _orbital_nodes.size()) * i
		var angle = _orbital_angle + angle_offset

		# 円周上の位置を計算
		var offset = Vector2(
			cos(angle) * effective_radius,
			sin(angle) * effective_radius
		)

		# プレイヤーからの相対位置に配置
		orbital.position = offset


## Orbital衛星の衝突処理
func _on_orbital_hit(body: Node2D, orbital: Area2D) -> void:
	if body.has_method("take_damage"):
		var damage = _calculate_damage()
		body.take_damage(damage)


## 連鎖ダメージ処理（再帰）
func _deal_chain_damage(target: Node, damage: int, remaining_chains: int, hit_list: Array) -> void:
	if target == null or not is_instance_valid(target):
		return
	if remaining_chains <= 0:
		return
	if hit_list.has(target):
		return  # 同じ敵に2度当たらないようにする

	# ダメージを与える
	if target.has_method("take_damage"):
		target.take_damage(damage)

	hit_list.append(target)

	# 次の連鎖対象を探す
	if remaining_chains > 1:
		var next_target = _find_nearest_enemy_from(target, hit_list)
		if next_target != null:
			var next_damage = int(damage * weapon_data.chain_damage_falloff)
			_deal_chain_damage(next_target, next_damage, remaining_chains - 1, hit_list)


## 指定位置から最も近い敵を探す（除外リスト付き）
func _find_nearest_enemy_from(from_node: Node, exclude_list: Array) -> Node:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var nearest: Node = null
	# 範囲拡大を考慮した連鎖範囲
	var weapon_manager = owner_player.get_node_or_null("WeaponManager")
	var effective_range = weapon_data.chain_range
	if weapon_manager != null:
		effective_range *= weapon_manager.area_multiplier

	var min_distance: float = effective_range * effective_range  # 範囲制限

	for enemy in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if exclude_list.has(enemy):
			continue

		var distance = from_node.global_position.distance_squared_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = enemy

	return nearest


## マルチショット処理（追加弾を発射）
func _apply_multishot(pos: Vector2, base_direction: Vector2, damage: int, homing: bool, pierce: int = 0) -> void:
	var weapon_manager = owner_player.get_node_or_null("WeaponManager")
	if weapon_manager == null or weapon_manager.multishot_count <= 0:
		return

	# 追加弾数分だけ発射（基準方向の両側に扇状に展開）
	var spread_angle = deg_to_rad(15.0)  # 1弾あたり15度の角度差
	var half_count = weapon_manager.multishot_count / 2

	for i in range(weapon_manager.multishot_count):
		# 中心から左右に交互に配置
		var offset_index = (i + 1) / 2
		var angle_offset = spread_angle * offset_index
		if i % 2 == 0:
			angle_offset = -angle_offset  # 偶数は左側

		# 方向ベクトルを回転
		var rotated_direction = base_direction.rotated(angle_offset)
		_spawn_projectile(pos, rotated_direction, damage, homing, pierce)


## 範囲拡大を適用（武器の各種範囲パラメータに反映）
func _apply_area_multiplier() -> void:
	var weapon_manager = owner_player.get_node_or_null("WeaponManager")
	if weapon_manager == null or weapon_data == null:
		return

	var multiplier = weapon_manager.area_multiplier

	# Orbital武器の場合、回転半径を拡大
	if weapon_data.attack_type == Weapon.AttackType.ORBITAL:
		for orbital in _orbital_nodes:
			if is_instance_valid(orbital):
				# 衛星のコリジョンサイズも拡大
				var shape_node = orbital.get_node_or_null("CollisionShape2D")
				if shape_node != null and shape_node.shape is CircleShape2D:
					shape_node.shape.radius *= multiplier

	# Chain武器の場合、連鎖範囲を拡大（weapon_dataを直接変更しないよう注意）
	# 実際の範囲計算は_find_nearest_enemy_from()内で行われるため、ここでは何もしない


## マズルフラッシュエフェクトを生成
func _spawn_muzzle_flash(pos: Vector2) -> void:
	if owner_player == null:
		return

	var flash = MUZZLE_FLASH_SCENE.instantiate()
	var game_scene = owner_player.get_parent()
	if game_scene != null:
		game_scene.add_child(flash)
		flash.global_position = pos
		flash.emitting = true
		flash.get_node("Timer").start()
