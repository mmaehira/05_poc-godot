class_name BomberAttack extends EnemyAttack

## Bomber攻撃（予告サークル→範囲爆発）

const _MeleeArea = preload("res://scripts/weapons/melee_area.gd")

const EXPLOSION_DELAY: float = 0.8
const EXPLOSION_RADIUS: float = 50.0

func attack() -> void:
	if _owner_enemy == null or _player == null:
		return
	if not is_instance_valid(_owner_enemy) or not is_instance_valid(_player):
		return

	# 着弾予測地点 = プレイヤーの現在位置
	var target_pos = _player.global_position

	# 予告サークルを表示
	_spawn_warning_circle(target_pos)

	# 遅延爆発（game_sceneに追加：敵死亡でもタイマーが残る）
	var scene = _owner_enemy.get_parent()
	if scene:
		var timer = Timer.new()
		timer.wait_time = EXPLOSION_DELAY
		timer.one_shot = true
		timer.timeout.connect(_explode.bind(target_pos, scene))
		scene.add_child(timer)
		timer.start()

func _spawn_warning_circle(pos: Vector2) -> void:
	var warning = Node2D.new()
	warning.global_position = pos

	# 半透明の赤い円
	var visual = Polygon2D.new()
	var points = PackedVector2Array()
	for i in range(24):
		var angle = i * TAU / 24
		points.append(Vector2(cos(angle), sin(angle)) * EXPLOSION_RADIUS)
	visual.polygon = points
	visual.color = Color(1.0, 0.0, 0.0, 0.3)
	warning.add_child(visual)

	# リングアニメ
	var ring = Line2D.new()
	var ring_points = PackedVector2Array()
	for i in range(25):
		var angle = i * TAU / 24
		ring_points.append(Vector2(cos(angle), sin(angle)) * EXPLOSION_RADIUS)
	ring.points = ring_points
	ring.width = 2.0
	ring.default_color = Color(1.0, 0.0, 0.0, 0.6)
	warning.add_child(ring)

	var game_scene = _owner_enemy.get_parent()
	if game_scene:
		game_scene.add_child(warning)

	# EXPLOSION_DELAY後に消す
	var timer = Timer.new()
	timer.wait_time = EXPLOSION_DELAY
	timer.one_shot = true
	timer.timeout.connect(warning.queue_free)
	warning.add_child(timer)
	timer.start()

func _explode(pos: Vector2, cached_scene: Node) -> void:
	# MeleeArea で範囲ダメージ
	var area = _MeleeArea.new()
	var game_scene = cached_scene if is_instance_valid(cached_scene) else null
	if game_scene == null:
		game_scene = _player.get_parent() if is_instance_valid(_player) else null
	if game_scene:
		game_scene.add_child(area)
		area.initialize(pos, attack_damage, EXPLOSION_RADIUS)
		# initialize()後にオーバーライド: Bomber爆発はプレイヤーに当たる
		area.collision_mask = 0
		area.set_collision_mask_value(1, true)  # プレイヤーレイヤー

		# 爆発パーティクル（毒緑）
		var particles = CPUParticles2D.new()
		particles.emitting = true
		particles.one_shot = true
		particles.amount = 16
		particles.lifetime = 0.5
		particles.explosiveness = 1.0
		particles.direction = Vector2.ZERO
		particles.spread = 180.0
		particles.initial_velocity_min = 80.0
		particles.initial_velocity_max = 160.0
		particles.damping_min = 150.0
		particles.damping_max = 250.0
		particles.scale_amount_min = 3.0
		particles.scale_amount_max = 5.0
		particles.color = Color(0.46, 1.0, 0.0, 0.8)  # 毒緑
		particles.gravity = Vector2.ZERO
		game_scene.add_child(particles)
		particles.global_position = pos
		var ptimer = Timer.new()
		ptimer.wait_time = 0.8
		ptimer.one_shot = true
		ptimer.timeout.connect(particles.queue_free)
		particles.add_child(ptimer)
		ptimer.start()
