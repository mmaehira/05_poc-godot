class_name ShooterEnemy
extends Enemy

## Shooter（単発射撃型）
## 距離を保ちながら予告→単発弾を発射

const _AIKeepDistance = preload("res://resources/ai_keep_distance.gd")
const _ShooterAttack = preload("res://scripts/enemies/attacks/shooter_attack.gd")

var _attack_node = null

func _ready() -> void:
	super._ready()
	_apply_stats()

func initialize(pos: Vector2, target_player: Node) -> void:
	_apply_stats()
	super.initialize(pos, target_player)
	if ai_controller is _AIKeepDistance:
		ai_controller.keep_distance = 180.0
		ai_controller.max_range = 250.0
		ai_controller.reset()

	# 攻撃ノードを初期化
	if _attack_node == null:
		_attack_node = _ShooterAttack.new()
		_attack_node.attack_damage = 8
		_attack_node.attack_interval = 2.0
		_attack_node.projectile_speed = 180.0
		_attack_node.attack_range = 250.0
		add_child(_attack_node)
	_attack_node.initialize(self, target_player)

func _apply_stats() -> void:
	max_hp = 25
	speed = 80.0
	contact_damage = 5
	exp_value = 7
	current_hp = max_hp
	if ai_controller == null:
		ai_controller = _AIKeepDistance.new()
