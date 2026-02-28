class_name MeleeArea extends Area2D

## 近接円範囲攻撃のダメージ判定エリア
##
## 責務:
## - プレイヤー周囲の円形ダメージ判定
## - 一定時間後に自動消滅（queue_free）

var damage: int = 0
var _lifetime: float = 0.4
var _elapsed: float = 0.0
var _hit_enemies: Array = []
var _checked_initial: bool = false

func initialize(pos: Vector2, dmg: int, radius: float) -> void:
	global_position = pos
	damage = dmg
	_elapsed = 0.0
	_hit_enemies.clear()
	_checked_initial = false

	# コリジョンシェイプを設定
	var shape_node = get_node_or_null("CollisionShape2D")
	if shape_node == null:
		shape_node = CollisionShape2D.new()
		shape_node.name = "CollisionShape2D"
		add_child(shape_node)

	var circle = CircleShape2D.new()
	circle.radius = radius
	shape_node.shape = circle

	# コリジョン設定: 敵に当たる
	collision_layer = 0
	collision_mask = 2  # 敵レイヤー
	monitoring = true
	monitorable = false

	visible = true
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_elapsed += delta

	# 2フレーム目で初期オーバーラップをチェック
	if not _checked_initial and _elapsed > 0.05:
		_checked_initial = true
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body.has_method("take_damage") and not _hit_enemies.has(body):
				body.take_damage(damage)
				_hit_enemies.append(body)

	if _elapsed >= _lifetime:
		_destroy()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not _hit_enemies.has(body):
		body.take_damage(damage)
		_hit_enemies.append(body)

func _destroy() -> void:
	visible = false
	monitoring = false
	queue_free()
