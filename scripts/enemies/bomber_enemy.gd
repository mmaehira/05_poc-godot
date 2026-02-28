class_name BomberEnemy
extends Enemy

## Bomber（範囲爆発型）
## 距離を保ちながら着弾予告→遅延範囲爆発

const _AIKeepDistance = preload("res://resources/ai_keep_distance.gd")
const _BomberAttack = preload("res://scripts/enemies/attacks/bomber_attack.gd")

var _attack_node = null

func _ready() -> void:
	super._ready()
	_apply_stats()

func initialize(pos: Vector2, target_player: Node) -> void:
	_apply_stats()
	super.initialize(pos, target_player)
	if ai_controller is _AIKeepDistance:
		ai_controller.keep_distance = 200.0
		ai_controller.max_range = 300.0
		ai_controller.reset()

	if _attack_node == null:
		_attack_node = _BomberAttack.new()
		_attack_node.attack_damage = 15
		_attack_node.attack_interval = 3.0
		_attack_node.attack_range = 300.0
		add_child(_attack_node)
	_attack_node.initialize(self, target_player)

func _apply_stats() -> void:
	max_hp = 35
	speed = 60.0
	contact_damage = 5
	exp_value = 10
	current_hp = max_hp
	if ai_controller == null:
		ai_controller = _AIKeepDistance.new()
