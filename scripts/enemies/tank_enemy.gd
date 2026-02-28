class_name TankEnemy
extends Enemy

## Tank（重装型）
## 超高HP・低速・高接触ダメージ

const _AIChasePlayer = preload("res://resources/ai_chase_player.gd")

func _ready() -> void:
	super._ready()
	_apply_stats()

func initialize(pos: Vector2, target_player: Node) -> void:
	_apply_stats()
	super.initialize(pos, target_player)

func _apply_stats() -> void:
	max_hp = 200
	speed = 40.0
	contact_damage = 25
	exp_value = 25
	current_hp = max_hp
	if ai_controller == null:
		ai_controller = _AIChasePlayer.new()
