class_name HeavyEnemy
extends Enemy

## HeavyEnemy（重装型）
##
## 特徴:
## - 高HP: 150（BasicEnemyの5倍）
## - 低速: 60（BasicEnemyの60%）
## - 高ダメージ: 20（BasicEnemyの2倍）
## - 高経験値: 20（BasicEnemyの4倍）

func _ready() -> void:
	super._ready()
	max_hp = 150
	speed = 60.0
	contact_damage = 20
	exp_value = 20
	current_hp = max_hp
