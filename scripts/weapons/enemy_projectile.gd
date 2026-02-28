class_name EnemyProjectile extends Area2D

## 敵弾クラス
##
## 責務:
## - 敵が発射する弾丸の移動処理
## - プレイヤーとの衝突判定（敵弾レイヤー4 → プレイヤーレイヤー1）

var damage: int = 10
var speed: float = 200.0
var direction: Vector2 = Vector2.ZERO
var lifetime: float = 5.0
var _elapsed_time: float = 0.0

func initialize(pos: Vector2, dir: Vector2, dmg: int) -> void:
	global_position = pos
	direction = dir.normalized()
	damage = dmg
	speed = 200.0    # デフォルト速度にリセット（呼び出し側が上書き可能）
	lifetime = 5.0   # デフォルト寿命にリセット
	_elapsed_time = 0.0

	# コリジョン設定: 敵弾レイヤー、プレイヤーにのみ当たる
	collision_layer = 0
	set_collision_layer_value(4, true)   # レイヤー4: 敵弾
	collision_mask = 0
	set_collision_mask_value(1, true)    # レイヤー1: プレイヤー

	monitoring = true
	monitorable = false
	visible = true
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_elapsed_time += delta

	if _elapsed_time >= lifetime:
		_destroy()
		return

	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		_destroy()

func _destroy() -> void:
	visible = false
	monitoring = false
	PoolManager.return_enemy_projectile(self)
