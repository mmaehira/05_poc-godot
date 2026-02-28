class_name SwarmEnemy
extends Enemy

## Swarm（群れ型）
## 弱いが大量に出現、速度にランダムばらつき

const _AISwarmChase = preload("res://resources/ai_swarm_chase.gd")

func _ready() -> void:
	super._ready()
	_apply_stats()

func initialize(pos: Vector2, target_player: Node) -> void:
	_apply_stats()
	super.initialize(pos, target_player)
	if ai_controller is _AISwarmChase:
		ai_controller.reset()

func _apply_stats() -> void:
	max_hp = 10
	speed = 90.0
	contact_damage = 3
	exp_value = 2
	current_hp = max_hp
	if ai_controller == null:
		ai_controller = _AISwarmChase.new()
