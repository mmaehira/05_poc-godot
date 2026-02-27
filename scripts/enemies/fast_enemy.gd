class_name FastEnemy
extends Enemy

## FastEnemy（高速型）
##
## 特徴:
## - 低HP: 15（BasicEnemyの50%）
## - 高速: 180（BasicEnemyの180%）
## - 低ダメージ: 5（BasicEnemyの50%）
## - 低経験値: 3（BasicEnemyより少ない）

func _ready() -> void:
	super._ready()
	max_hp = 15
	speed = 180.0
	contact_damage = 5
	exp_value = 3
	current_hp = max_hp
