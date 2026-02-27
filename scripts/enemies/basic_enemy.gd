class_name BasicEnemy
extends Enemy

func _ready() -> void:
    super._ready()
    max_hp = 30
    speed = 100.0
    contact_damage = 10
    exp_value = 5
    current_hp = max_hp
