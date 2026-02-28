class_name ChargerEnemy
extends Enemy

## Charger（突進型）
## 一定距離で予告→高速突進→クールダウン

const _AIRush = preload("res://resources/ai_rush.gd")

func _ready() -> void:
	super._ready()
	_apply_stats()

func initialize(pos: Vector2, target_player: Node) -> void:
	_apply_stats()
	super.initialize(pos, target_player)
	if ai_controller is _AIRush:
		ai_controller.reset()

func _apply_stats() -> void:
	max_hp = 40
	speed = 70.0
	contact_damage = 15
	exp_value = 8
	current_hp = max_hp
	if ai_controller == null:
		ai_controller = _AIRush.new()
