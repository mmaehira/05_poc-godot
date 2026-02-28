class_name AISwarmChase extends AIController

## 群れ追跡AI（Swarm用）
## プレイヤーに直進するが、速度にランダムばらつきを持つ

var _speed_variance: float = 0.0
var _base_speed: float = 0.0
var _initialized: bool = false

func calculate_direction(enemy: Node, player: Node, delta: float) -> Vector2:
	if not _initialized:
		_initialized = true
		_base_speed = enemy.speed
		_speed_variance = randf_range(-20.0, 20.0)
		enemy.speed = _base_speed + _speed_variance

	return (player.global_position - enemy.global_position).normalized()

func reset() -> void:
	_initialized = false
	_speed_variance = 0.0
	_base_speed = 0.0
