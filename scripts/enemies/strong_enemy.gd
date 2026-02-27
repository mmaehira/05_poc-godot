class_name StrongEnemy
extends Enemy

func _ready() -> void:
    super._ready()
    max_hp = 80
    speed = 80.0
    contact_damage = 20
    exp_value = 15
    current_hp = max_hp
