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

## BARRIER_DOT用
var _barrier_node: Area2D = null
var _barrier_enemies: Dictionary = {}
var _dot_timer: float = 0.0

## 多段攻撃用（MELEE_CIRCLE）
var _multi_hit_remaining: int = 0
var _multi_hit_timer: float = 0.0

## 連射用（SHOTGUN）
var _burst_remaining: int = 0
var _burst_timer: float = 0.0
var _burst_direction: Vector2 = Vector2.ZERO

## 診断用
var _debug_logged: bool = false

## エフェクト用プリロード
const MUZZLE_FLASH_SCENE = preload("res://scenes/effects/muzzle_flash.tscn")

## class_name解決順序の問題を回避するためpreload
const _MeleeArea = preload("res://scripts/weapons/melee_area.gd")
const _PlacedZone = preload("res://scripts/weapons/placed_zone.gd")


func _exit_tree() -> void:
	# バリアノードのクリーンアップ
	if _barrier_node != null and is_instance_valid(_barrier_node):
		# スローした敵の速度を元に戻す
		for enemy in _barrier_enemies:
			if is_instance_valid(enemy) and "speed" in enemy:
				enemy.speed = _barrier_enemies[enemy]
		_barrier_enemies.clear()
		_barrier_node.queue_free()
		_barrier_node = null


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

	# BARRIER_DOT武器は初回から展開
	if weapon.attack_type == Weapon.AttackType.BARRIER_DOT:
		_initialize_barrier()

	# 範囲拡大を適用
	_apply_area_multiplier()


func _process(delta: float) -> void:
	if not _debug_logged:
		_debug_logged = true
		print("[WeaponInstance診断] weapon=%s, type=%s, player=%s" % [
			weapon_data.weapon_name if weapon_data else "null",
			weapon_data.attack_type if weapon_data else -1,
			owner_player != null
		])
	if weapon_data == null or owner_player == null:
		return

	_attack_timer += delta

	# バリアDoTの更新
	if weapon_data.attack_type == Weapon.AttackType.BARRIER_DOT:
		_update_barrier_dot(delta)

	# 多段攻撃の処理（MELEE_CIRCLE）
	if _multi_hit_remaining > 0:
		_multi_hit_timer += delta
		var interval = 0.2 if current_level >= 5 else 0.3
		if _multi_hit_timer >= interval:
			_multi_hit_timer = 0.0
			_multi_hit_remaining -= 1
			var damage = _calculate_damage()
			var radius = weapon_data.melee_radius + (current_level - 1) * 10.0
			_spawn_melee_area(damage, radius)

	# 連射の処理（SHOTGUN）
	if _burst_remaining > 0:
		_burst_timer += delta
		if _burst_timer >= 0.15:
			_burst_timer = 0.0
			_burst_remaining -= 1
			var damage = _calculate_damage()
			var counts = [3, 5, 5, 7, 7]
			var count = counts[clampi(current_level - 1, 0, 4)]
			_fire_shotgun_burst(_burst_direction, damage, count)

	if _can_attack():
		_attack()
		_attack_timer = 0.0


func level_up() -> void:
	current_level += 1
	print("武器レベルアップ: %s Lv.%d" % [weapon_data.weapon_name, current_level])

	# BARRIER_DOT: レベルアップ時にバリアの半径を更新
	if weapon_data != null and weapon_data.attack_type == Weapon.AttackType.BARRIER_DOT:
		if _barrier_node != null and is_instance_valid(_barrier_node):
			var shape_node = _barrier_node.get_node_or_null("CollisionShape2D")
			if shape_node != null and shape_node.shape is CircleShape2D:
				shape_node.shape.radius = weapon_data.barrier_radius + (current_level - 1) * 15.0


func _can_attack() -> bool:
	if weapon_data == null:
		return false
	# BARRIER_DOTはattack()を使わない（_process内で管理）
	if weapon_data.attack_type == Weapon.AttackType.BARRIER_DOT:
		return false
	return _attack_timer >= weapon_data.attack_interval


func _attack() -> void:
	if weapon_data == null or owner_player == null:
		return

	match weapon_data.attack_type:
		Weapon.AttackType.MELEE_CIRCLE:
			_attack_melee_circle()
		Weapon.AttackType.RUSH_EXPLODE:
			_attack_rush_explode()
		Weapon.AttackType.PENETRATE_LINE:
			_attack_penetrate_line()
		Weapon.AttackType.SPLIT_SHOT:
			_attack_split_shot()
		Weapon.AttackType.HOMING:
			_attack_homing()
		Weapon.AttackType.SHOTGUN:
			_attack_shotgun()
		Weapon.AttackType.PLACE_DOT:
			_attack_place_dot()


## W1. MELEE_CIRCLE（マクロファージ・ブレード）
func _attack_melee_circle() -> void:
	var damage = _calculate_damage()
	var radius = weapon_data.melee_radius + (current_level - 1) * 10.0
	var hit_count = 3 if current_level >= 5 else (2 if current_level >= 3 else 1)

	_spawn_melee_area(damage, radius)
	AudioManager.play_sfx("shoot", -8.0)

	if hit_count > 1:
		_multi_hit_remaining = hit_count - 1
		_multi_hit_timer = 0.0


func _spawn_melee_area(dmg: int, radius: float) -> void:
	var area = _MeleeArea.new()
	var game_scene = owner_player.get_parent()
	if game_scene:
		game_scene.add_child(area)
		area.initialize(owner_player.global_position, dmg, radius)
	_spawn_melee_effect(owner_player.global_position, radius)


## W2. RUSH_EXPLODE（ニュートロ・チャージ）
func _attack_rush_explode() -> void:
	var nearest = _find_nearest_enemy()
	var direction: Vector2
	if nearest:
		direction = (nearest.global_position - owner_player.global_position).normalized()
	else:
		direction = owner_player.velocity.normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.RIGHT

	var damage = _calculate_damage()
	var count = 3 if current_level >= 5 else (2 if current_level >= 3 else 1)
	var expl_radius = weapon_data.explosion_radius + (current_level - 1) * 7.5

	for i in range(count):
		var angle_offset = 0.0
		if count > 1:
			angle_offset = deg_to_rad(15.0) * (i - (count - 1) / 2.0)
		var dir = direction.rotated(angle_offset)
		_spawn_rush_projectile(owner_player.global_position, dir, damage, expl_radius)

	AudioManager.play_sfx("shoot", -8.0)


func _spawn_rush_projectile(pos: Vector2, dir: Vector2, dmg: int, expl_radius: float) -> void:
	var projectile = PoolManager.spawn_projectile(pos, dir, dmg)
	if projectile != null:
		projectile.speed = weapon_data.rush_speed
		projectile.attack_type = weapon_data.attack_type
		projectile.explosion_radius = expl_radius
		_spawn_muzzle_flash(pos)


## W3. PENETRATE_LINE（キラーTレーザー）
func _attack_penetrate_line() -> void:
	var nearest = _find_nearest_enemy()
	var direction: Vector2
	if nearest:
		direction = (nearest.global_position - owner_player.global_position).normalized()
	else:
		direction = owner_player.velocity.normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.RIGHT

	var damage = _calculate_damage()
	var count = 3 if current_level >= 5 else (2 if current_level >= 3 else 1)

	for i in range(count):
		var angle_offset = 0.0
		if count > 1:
			angle_offset = deg_to_rad(10.0) * (i - (count - 1) / 2.0)
		var dir = direction.rotated(angle_offset)
		_spawn_projectile(owner_player.global_position, dir, damage, false, -1)  # 無限貫通

	AudioManager.play_sfx("shoot", -8.0)


## W4. SPLIT_SHOT（抗体スプリッター）
func _attack_split_shot() -> void:
	var nearest = _find_nearest_enemy()
	var direction: Vector2
	if nearest:
		direction = (nearest.global_position - owner_player.global_position).normalized()
	else:
		direction = owner_player.velocity.normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.RIGHT

	var damage = _calculate_damage()
	var projectile = PoolManager.spawn_projectile(owner_player.global_position, direction, damage)
	if projectile:
		projectile.speed = weapon_data.projectile_speed
		projectile.attack_type = weapon_data.attack_type
		projectile.split_count = weapon_data.split_count + (1 if current_level >= 2 else 0) + (1 if current_level >= 4 else 0)
		projectile.split_generation = 3 if current_level >= 5 else (2 if current_level >= 3 else 1)

	_spawn_muzzle_flash(owner_player.global_position)
	AudioManager.play_sfx("shoot", -10.0)


## W5. HOMING（ナノ・ホーミング球）
func _attack_homing() -> void:
	var nearest = _find_nearest_enemy()
	var direction: Vector2
	if nearest:
		direction = (nearest.global_position - owner_player.global_position).normalized()
	else:
		direction = owner_player.velocity.normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.RIGHT

	var damage = _calculate_damage()
	var counts = [1, 2, 3, 3, 5]
	var count = counts[clampi(current_level - 1, 0, 4)]

	for i in range(count):
		var angle_offset = deg_to_rad(20.0) * (i - (count - 1) / 2.0) if count > 1 else 0.0
		var dir = direction.rotated(angle_offset)
		_spawn_projectile(owner_player.global_position, dir, damage, true)

	_spawn_muzzle_flash(owner_player.global_position)
	AudioManager.play_sfx("shoot", -10.0)


## W6. BARRIER_DOT（サイトカイン・リング）
## 初回の_attack()呼び出しはないが、initialize()からバリアを展開する
func _attack_barrier_dot() -> void:
	# _can_attack()でfalseを返すため、このメソッドは呼ばれない
	# バリアはinitialize()で展開済み
	pass


func _initialize_barrier() -> void:
	if _barrier_node != null:
		return  # 既に展開済み

	_barrier_node = Area2D.new()
	_barrier_node.name = "CytokineBarrier"

	var shape_node = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = weapon_data.barrier_radius + (current_level - 1) * 15.0
	shape_node.shape = circle
	_barrier_node.add_child(shape_node)

	_barrier_node.collision_layer = 0
	_barrier_node.set_collision_layer_value(6, true)
	_barrier_node.collision_mask = 0
	_barrier_node.set_collision_mask_value(2, true)

	_barrier_node.body_entered.connect(_on_barrier_entered)
	_barrier_node.body_exited.connect(_on_barrier_exited)

	owner_player.add_child(_barrier_node)

	# バリアビジュアルを追加
	var radius = weapon_data.barrier_radius + (current_level - 1) * 15.0
	_add_barrier_visual(radius)


func _on_barrier_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body is CharacterBody2D:
		if _barrier_enemies.has(body):
			return
		var original_speed = body.speed if "speed" in body else 100.0
		_barrier_enemies[body] = original_speed
		var slow_factors = [0.6, 0.55, 0.5, 0.45, 0.35]
		var slow = slow_factors[clampi(current_level - 1, 0, 4)]
		body.speed = original_speed * slow


func _on_barrier_exited(body: Node2D) -> void:
	if _barrier_enemies.has(body):
		if is_instance_valid(body) and "speed" in body:
			body.speed = _barrier_enemies[body]
		_barrier_enemies.erase(body)


func _update_barrier_dot(delta: float) -> void:
	if _barrier_node == null or not is_instance_valid(_barrier_node):
		return

	# 無効なエントリのクリーンアップ
	var invalid_enemies: Array = []
	for enemy in _barrier_enemies:
		if not is_instance_valid(enemy) or not enemy.is_inside_tree():
			invalid_enemies.append(enemy)
	for enemy in invalid_enemies:
		_barrier_enemies.erase(enemy)

	_dot_timer += delta
	var intervals = [0.8, 0.7, 0.6, 0.5, 0.4]
	var interval = intervals[clampi(current_level - 1, 0, 4)]

	if _dot_timer >= interval:
		_dot_timer -= interval
		var damages = [5, 7, 9, 12, 15]
		var dot_dmg = damages[clampi(current_level - 1, 0, 4)]

		# WeaponManagerのダメージ倍率を適用
		var weapon_manager = owner_player.get_node_or_null("WeaponManager")
		if weapon_manager:
			dot_dmg = int(dot_dmg * weapon_manager.get_damage_multiplier())

		var bodies = _barrier_node.get_overlapping_bodies()
		for body in bodies:
			if body.has_method("take_damage"):
				body.take_damage(dot_dmg)


## W7. SHOTGUN（ファゴサイト・バースト）
func _attack_shotgun() -> void:
	var nearest = _find_nearest_enemy()
	var direction: Vector2
	if nearest:
		direction = (nearest.global_position - owner_player.global_position).normalized()
	else:
		direction = owner_player.velocity.normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.RIGHT

	var damage = _calculate_damage()
	var counts = [3, 5, 5, 7, 7]
	var count = counts[clampi(current_level - 1, 0, 4)]

	_fire_shotgun_burst(direction, damage, count)

	# 2連射（Lv3以降）
	if current_level >= 3:
		_burst_remaining = 1
		_burst_timer = 0.0
		_burst_direction = direction

	AudioManager.play_sfx("shoot", -8.0)


func _fire_shotgun_burst(direction: Vector2, damage: int, count: int) -> void:
	var spread = deg_to_rad(weapon_data.spread_angle)
	for i in range(count):
		var t = float(i) / float(max(count - 1, 1))
		var angle_offset = lerp(-spread / 2.0, spread / 2.0, t)
		var dir = direction.rotated(angle_offset)
		var proj = PoolManager.spawn_projectile(owner_player.global_position, dir, damage)
		if proj:
			proj.speed = weapon_data.projectile_speed
			proj.attack_type = weapon_data.attack_type
			proj.lifetime = 0.6  # 短射程

	_spawn_muzzle_flash(owner_player.global_position)


## W8. PLACE_DOT（インフラマ・スパイク）
func _attack_place_dot() -> void:
	var damage = _calculate_damage()
	var counts = [1, 2, 2, 3, 4]
	var count = counts[clampi(current_level - 1, 0, 4)]
	var duration = weapon_data.place_duration + (current_level - 1) * 0.5
	var radius = weapon_data.place_radius + (current_level - 1) * 7.5

	for i in range(count):
		var offset_angle = randf() * TAU
		var offset_dist = randf_range(100.0, 200.0)
		var pos = owner_player.global_position + Vector2(cos(offset_angle), sin(offset_angle)) * offset_dist

		var zone = _PlacedZone.new()
		var game_scene = owner_player.get_parent()
		if game_scene:
			game_scene.add_child(zone)
			zone.initialize(pos, damage, radius, duration, weapon_data.dot_interval)

	AudioManager.play_sfx("shoot", -10.0)


## 共通ユーティリティ

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
		projectile.attack_type = weapon_data.attack_type
		projectile.pierce_count = pierce
		_spawn_muzzle_flash(pos)


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


## 範囲拡大を適用（各攻撃メソッド内で動的に適用するため、ここでは何もしない）
func _apply_area_multiplier() -> void:
	var weapon_manager = owner_player.get_node_or_null("WeaponManager")
	if weapon_manager == null or weapon_data == null:
		return
	# area_multiplierは各攻撃メソッド内で動的に適用するため、ここでは何もしない
	pass


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


## 汎用パーティクルヘルパー
func _spawn_particles(pos: Vector2, amount: int, lifetime: float, color: Color,
		velocity_min: float = 50.0, velocity_max: float = 100.0,
		spread: float = 180.0, scale_min: float = 2.0, scale_max: float = 4.0) -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = amount
	particles.lifetime = lifetime
	particles.explosiveness = 1.0
	particles.direction = Vector2.ZERO
	particles.spread = spread
	particles.initial_velocity_min = velocity_min
	particles.initial_velocity_max = velocity_max
	particles.damping_min = 150.0
	particles.damping_max = 250.0
	particles.scale_amount_min = scale_min
	particles.scale_amount_max = scale_max
	particles.color = color
	particles.gravity = Vector2.ZERO

	var game_scene = owner_player.get_parent()
	if game_scene:
		game_scene.add_child(particles)
		particles.global_position = pos
		var timer = Timer.new()
		timer.wait_time = lifetime + 0.3
		timer.one_shot = true
		timer.timeout.connect(particles.queue_free)
		particles.add_child(timer)
		timer.start()


## W1. マクロファージ・ブレード斬撃波パーティクル
func _spawn_melee_effect(pos: Vector2, radius: float) -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 12
	particles.lifetime = 0.3
	particles.explosiveness = 1.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = radius * 0.5
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 120.0
	particles.damping_min = 200.0
	particles.damping_max = 300.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = Color(0.0, 0.9, 1.0, 0.8)  # シアン
	particles.gravity = Vector2.ZERO

	var game_scene = owner_player.get_parent()
	if game_scene:
		game_scene.add_child(particles)
		particles.global_position = pos
		var timer = Timer.new()
		timer.wait_time = 0.5
		timer.one_shot = true
		timer.timeout.connect(particles.queue_free)
		particles.add_child(timer)
		timer.start()


## W6. サイトカイン・リング バリアビジュアル追加
func _add_barrier_visual(radius: float) -> void:
	# 半透明シアンの円（内側）
	var visual = Polygon2D.new()
	visual.name = "BarrierVisual"
	var points = PackedVector2Array()
	for i in range(32):
		var angle = i * TAU / 32
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	visual.polygon = points
	visual.color = Color(0.0, 0.9, 1.0, 0.15)  # 半透明シアン
	_barrier_node.add_child(visual)

	# 外周リング
	var ring = Line2D.new()
	ring.name = "BarrierRing"
	var ring_points = PackedVector2Array()
	for i in range(33):
		var angle = i * TAU / 32
		ring_points.append(Vector2(cos(angle), sin(angle)) * radius)
	ring.points = ring_points
	ring.width = 2.0
	ring.default_color = Color(0.0, 0.9, 1.0, 0.4)
	_barrier_node.add_child(ring)
