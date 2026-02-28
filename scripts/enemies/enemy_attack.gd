class_name EnemyAttack extends Node

## 敵攻撃基底クラス
##
## 責務:
## - 攻撃タイミングの制御
## - プレイヤーの射程内判定
## - サブクラスで attack() をオーバーライド

@export var attack_damage: int = 10
@export var attack_interval: float = 2.0
@export var projectile_speed: float = 200.0
@export var attack_range: float = 300.0

var _attack_timer: float = 0.0
var _can_attack: bool = true
var _owner_enemy: Node = null
var _player: Node = null

func initialize(enemy: Node, player: Node) -> void:
	_owner_enemy = enemy
	_player = player
	_attack_timer = 0.0
	_can_attack = true

func _process(delta: float) -> void:
	if _owner_enemy == null or _player == null:
		return
	if not is_instance_valid(_player):
		return

	if not _can_attack:
		_attack_timer += delta
		if _attack_timer >= attack_interval:
			_can_attack = true
			_attack_timer = 0.0
		return

	if _is_player_in_range():
		attack()
		_can_attack = false
		_attack_timer = 0.0

func _is_player_in_range() -> bool:
	if _owner_enemy == null or _player == null:
		return false
	var distance = _owner_enemy.global_position.distance_to(_player.global_position)
	return distance <= attack_range

func get_direction_to_player() -> Vector2:
	if _owner_enemy == null or _player == null:
		return Vector2.RIGHT
	return (_player.global_position - _owner_enemy.global_position).normalized()

## サブクラスでオーバーライド
func attack() -> void:
	pass
