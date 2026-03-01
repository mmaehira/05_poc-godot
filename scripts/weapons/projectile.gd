class_name Projectile extends Area2D

## Projectileクラス
##
## 責務:
## - 弾丸の移動処理
## - 敵との衝突判定
## - ホーミング処理（オプション）
## - 爆発処理（RUSH_EXPLODE用）
## - 分裂処理（SPLIT_SHOT用）

var damage: int = 0
var speed: float = 300.0
var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 5.0
var is_homing: bool = false
var attack_type: int = 0:  # 武器タイプを保持
	set(value):
		attack_type = value
		_update_visual()
var weapon_icon: Texture2D = null:  # 武器アイコンテクスチャ（弾丸表示用）
	set(value):
		weapon_icon = value
		_update_visual()
var pierce_count: int = 0  # 貫通回数（0=貫通なし、-1=無限貫通）
var _elapsed_time: float = 0.0
var _hit_enemies: Array = []  # 既にヒットした敵を記録（連続ヒット防止）

## 爆発用（RUSH_EXPLODE）
var explosion_radius: float = 0.0

## 分裂用（SPLIT_SHOT）
var split_count: int = 0
var split_generation: int = 0
var split_distance: float = 150.0
var _distance_traveled: float = 0.0
var _has_split: bool = false

func initialize(pos: Vector2, dir: Vector2, dmg: int) -> void:
	global_position = pos
	direction = dir.normalized()
	damage = dmg
	speed = 300.0
	lifetime = 5.0
	is_homing = false
	attack_type = 0
	weapon_icon = null
	pierce_count = 0
	_elapsed_time = 0.0
	_distance_traveled = 0.0
	_has_split = false
	_hit_enemies.clear()
	explosion_radius = 0.0
	split_count = 0
	split_generation = 0
	split_distance = 150.0
	_update_visual()

func _ready() -> void:
	# シグナル接続（重複防止）
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_elapsed_time += delta

	# 生存時間超過でプールに返却
	if _elapsed_time >= lifetime:
		_return_to_pool()
		return

	# ホーミング処理
	if is_homing:
		_update_homing_direction()

	# 移動
	var move = direction * speed * delta
	global_position += move

	# 分裂距離チェック（SPLIT_SHOT用）
	if split_generation > 0 and not _has_split:
		_distance_traveled += move.length()
		if _distance_traveled >= split_distance:
			_split()
			return

func _update_homing_direction() -> void:
	var nearest_enemy = _get_nearest_enemy()
	if nearest_enemy != null:
		var to_enemy = (nearest_enemy.global_position - global_position).normalized()
		# 徐々に方向転換（完全な追尾ではなく、緩やかに）
		direction = direction.lerp(to_enemy, 0.05)

func _get_nearest_enemy() -> Node:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var nearest: Node = null
	var min_distance: float = INF

	for enemy in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		var distance = global_position.distance_squared_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = enemy

	return nearest

func _on_area_entered(area: Area2D) -> void:
	# 敵との衝突処理（将来的に実装）
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		# 同じ敵に連続でヒットしないようにチェック
		if _hit_enemies.has(body):
			return

		body.take_damage(damage)
		_hit_enemies.append(body)

		# 爆発処理（RUSH_EXPLODE用）
		if explosion_radius > 0.0:
			_spawn_explosion()
			explosion_radius = 0.0
			call_deferred("_return_to_pool")
			return

		# 分裂処理（SPLIT_SHOT用: ヒット時も分裂）
		if split_generation > 0 and not _has_split:
			_split()
			return

		# W5. ホーミング命中エフェクト
		if is_homing:
			_spawn_homing_hit_effect()

		# 貫通処理
		if pierce_count == -1:
			# 無限貫通: 消滅しない
			_spawn_pierce_spark()
			return
		elif pierce_count > 0:
			# 貫通回数を減らす
			_spawn_pierce_spark()
			pierce_count -= 1
			return
		else:
			# 貫通なし: 通常通り消滅
			# 物理コールバック中なのでcall_deferred()を使用
			call_deferred("_return_to_pool")

func _split() -> void:
	if _has_split:
		return
	_has_split = true

	if split_count <= 0:
		call_deferred("_return_to_pool")
		return

	# W4. 抗体スプリッター 分裂パーティクル（白〜水色リングバースト）
	var split_particles = CPUParticles2D.new()
	split_particles.emitting = true
	split_particles.one_shot = true
	split_particles.amount = 8
	split_particles.lifetime = 0.3
	split_particles.explosiveness = 1.0
	split_particles.direction = Vector2.ZERO
	split_particles.spread = 180.0
	split_particles.initial_velocity_min = 50.0
	split_particles.initial_velocity_max = 80.0
	split_particles.damping_min = 100.0
	split_particles.damping_max = 200.0
	split_particles.scale_amount_min = 2.0
	split_particles.scale_amount_max = 3.0
	split_particles.color = Color(0.6, 0.9, 1.0, 0.8)  # 水色
	split_particles.gravity = Vector2.ZERO
	var split_game_scene = get_parent()
	if split_game_scene:
		split_game_scene.add_child(split_particles)
		split_particles.global_position = global_position
		var split_timer = Timer.new()
		split_timer.wait_time = 0.5
		split_timer.one_shot = true
		split_timer.timeout.connect(split_particles.queue_free)
		split_particles.add_child(split_timer)
		split_timer.start()

	var child_damage = int(damage * 0.7)
	var angle_step = TAU / split_count
	for i in range(split_count):
		var angle = angle_step * i
		var child_dir = Vector2(cos(angle), sin(angle))
		var child = PoolManager.spawn_projectile(global_position, child_dir, child_damage)
		if child:
			child.speed = speed
			child.weapon_icon = weapon_icon
			child.attack_type = attack_type
			child.split_count = split_count
			child.split_generation = split_generation - 1
			child.split_distance = 100.0  # 子弾は100pxで再分裂

	call_deferred("_return_to_pool")

## class_name解決順序の問題を回避するためpreload
const _MeleeArea = preload("res://scripts/weapons/melee_area.gd")

func _spawn_explosion() -> void:
	if explosion_radius <= 0.0:
		return
	var area = _MeleeArea.new()
	var game_scene = get_parent()
	if game_scene:
		game_scene.add_child(area)
		area.initialize(global_position, damage, explosion_radius)

		# W2. ニュートロ・チャージ 爆発パーティクル（オレンジ〜白バースト）
		var particles = CPUParticles2D.new()
		particles.emitting = true
		particles.one_shot = true
		particles.amount = 16
		particles.lifetime = 0.5
		particles.explosiveness = 1.0
		particles.direction = Vector2.ZERO
		particles.spread = 180.0
		particles.initial_velocity_min = 100.0
		particles.initial_velocity_max = 200.0
		particles.damping_min = 150.0
		particles.damping_max = 250.0
		particles.scale_amount_min = 3.0
		particles.scale_amount_max = 6.0
		particles.color = Color(1.0, 0.6, 0.0, 0.9)  # オレンジ
		particles.gravity = Vector2.ZERO

		game_scene.add_child(particles)
		particles.global_position = global_position
		var timer = Timer.new()
		timer.wait_time = 0.8
		timer.one_shot = true
		timer.timeout.connect(particles.queue_free)
		particles.add_child(timer)
		timer.start()


## W3. キラーTレーザー 貫通スパークパーティクル
func _spawn_pierce_spark() -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 6
	particles.lifetime = 0.2
	particles.explosiveness = 1.0
	particles.direction = direction
	particles.spread = 30.0
	particles.initial_velocity_min = 60.0
	particles.initial_velocity_max = 100.0
	particles.damping_min = 200.0
	particles.damping_max = 300.0
	particles.scale_amount_min = 1.5
	particles.scale_amount_max = 3.0
	particles.color = Color(1.0, 1.0, 1.0, 0.9)  # 白
	particles.gravity = Vector2.ZERO

	var game_scene = get_parent()
	if game_scene:
		game_scene.add_child(particles)
		particles.global_position = global_position
		var timer = Timer.new()
		timer.wait_time = 0.4
		timer.one_shot = true
		timer.timeout.connect(particles.queue_free)
		particles.add_child(timer)
		timer.start()


## W5. ナノ・ホーミング球 命中パーティクル（シアン小爆発）
func _spawn_homing_hit_effect() -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 8
	particles.lifetime = 0.3
	particles.explosiveness = 1.0
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 60.0
	particles.initial_velocity_max = 120.0
	particles.damping_min = 150.0
	particles.damping_max = 250.0
	particles.scale_amount_min = 1.5
	particles.scale_amount_max = 3.0
	particles.color = Color(0.0, 0.9, 1.0, 0.9)  # シアン
	particles.gravity = Vector2.ZERO

	var game_scene = get_parent()
	if game_scene:
		game_scene.add_child(particles)
		particles.global_position = global_position
		var timer = Timer.new()
		timer.wait_time = 0.5
		timer.one_shot = true
		timer.timeout.connect(particles.queue_free)
		particles.add_child(timer)
		timer.start()

func _return_to_pool() -> void:
	# 期限切れ時の爆発処理（RUSH_EXPLODE: 着弾しなくても爆発）
	if explosion_radius > 0.0:
		_spawn_explosion()
		explosion_radius = 0.0  # 二重爆発防止

	PoolManager.return_projectile(self)


func _update_visual() -> void:
	var visual = get_node_or_null("Visual")
	if visual == null or not visual.has_method("setup"):
		return

	const ProjectileVisual = preload("res://scripts/weapons/projectile_visual.gd")
	var vtype = ProjectileVisual.get_visual_type_from_weapon(attack_type)
	visual.setup(weapon_icon, vtype)
