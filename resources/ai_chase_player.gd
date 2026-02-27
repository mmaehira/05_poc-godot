class_name AIChasePlayer extends AIController

## AIChasePlayerクラス
##
## 責務:
## - プレイヤーを追跡する単純なAI

func calculate_direction(enemy: Node, player: Node, delta: float) -> Vector2:
	if player == null or enemy == null:
		return Vector2.ZERO

	return (player.global_position - enemy.global_position).normalized()
