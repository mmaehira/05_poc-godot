class_name PlacedZone extends Area2D

## 設置型DoTゾーン
##
## 責務:
## - 指定位置にダメージゾーンを設置
## - tick_intervalごとにゾーン内の敵にダメージ
## - place_duration後にフェードアウトして消滅

var dot_damage: int = 0
var tick_interval: float = 0.5
var place_duration: float = 3.0
var _elapsed: float = 0.0
var _tick_timer: float = 0.0
var _fading: bool = false

func initialize(pos: Vector2, dmg: int, radius: float, duration: float, interval: float) -> void:
	global_position = pos
	dot_damage = dmg
	place_duration = duration
	tick_interval = interval
	_elapsed = 0.0
	_tick_timer = 0.0
	_fading = false
	modulate.a = 1.0

	# コリジョンシェイプを設定
	var shape_node = get_node_or_null("CollisionShape2D")
	if shape_node == null:
		shape_node = CollisionShape2D.new()
		shape_node.name = "CollisionShape2D"
		add_child(shape_node)

	var circle = CircleShape2D.new()
	circle.radius = radius
	shape_node.shape = circle

	# コリジョン設定
	collision_layer = 0
	set_collision_layer_value(6, true)  # レイヤー6: バリア/設置物
	collision_mask = 0
	set_collision_mask_value(2, true)   # レイヤー2: 敵
	monitoring = true
	monitorable = false

	visible = true
	process_mode = Node.PROCESS_MODE_PAUSABLE

	# ゾーンビジュアルを生成
	_create_visual(radius)

func _process(delta: float) -> void:
	_elapsed += delta

	# 持続時間チェック
	if _elapsed >= place_duration:
		if not _fading:
			_fading = true
			_start_fade_out()
		return

	# DoTダメージ処理
	_tick_timer += delta
	if _tick_timer >= tick_interval:
		_tick_timer -= tick_interval
		_deal_dot_damage()

func _deal_dot_damage() -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(dot_damage)

func _start_fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_destroy)

func _destroy() -> void:
	monitoring = false
	visible = false
	queue_free()


## W8. インフラマ・スパイク ゾーンビジュアル生成
func _create_visual(radius: float) -> void:
	# 既存のビジュアルを削除（initialize再呼び出し対策）
	var old_visual = get_node_or_null("ZoneVisual")
	if old_visual:
		old_visual.queue_free()
	var old_ring = get_node_or_null("ZoneRing")
	if old_ring:
		old_ring.queue_free()
	var old_particles = get_node_or_null("ZoneParticles")
	if old_particles:
		old_particles.queue_free()

	# 半透明シアンの円（内側塗りつぶし）
	var visual = Polygon2D.new()
	visual.name = "ZoneVisual"
	var points = PackedVector2Array()
	for i in range(24):
		var angle = i * TAU / 24
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	visual.polygon = points
	visual.color = Color(0.0, 0.9, 1.0, 0.2)
	add_child(visual)

	# 外周リング
	var ring = Line2D.new()
	ring.name = "ZoneRing"
	var ring_points = PackedVector2Array()
	for i in range(25):
		var angle = i * TAU / 24
		ring_points.append(Vector2(cos(angle), sin(angle)) * radius)
	ring.points = ring_points
	ring.width = 1.5
	ring.default_color = Color(0.0, 0.9, 1.0, 0.5)
	add_child(ring)

	# 上昇パーティクル
	var particles = CPUParticles2D.new()
	particles.name = "ZoneParticles"
	particles.emitting = true
	particles.amount = 4
	particles.lifetime = 0.8
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = radius * 0.7
	particles.direction = Vector2(0.0, -1.0)
	particles.spread = 20.0
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 40.0
	particles.gravity = Vector2.ZERO
	particles.scale_amount_min = 1.5
	particles.scale_amount_max = 2.5
	particles.color = Color(0.0, 0.9, 1.0, 0.5)
	add_child(particles)
