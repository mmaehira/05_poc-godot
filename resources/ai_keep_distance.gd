class_name AIKeepDistance extends AIController

## 距離維持AI（遠距離攻撃型用）
## 一定距離を保ちつつ横移動

@export var keep_distance: float = 180.0
@export var max_range: float = 300.0
@export var strafe_speed_factor: float = 0.7

var _strafe_direction: float = 1.0  # 1.0 or -1.0
var _strafe_timer: float = 0.0
var _next_strafe_change: float = 3.0  # 次のstrafe切り替えまでの時間

func calculate_direction(enemy: Node, player: Node, delta: float) -> Vector2:
	var to_player = player.global_position - enemy.global_position
	var distance = to_player.length()
	var dir = to_player.normalized()

	# 横方向ベクトル
	var strafe = Vector2(-dir.y, dir.x) * _strafe_direction

	# ストレイフ方向の切り替え（閾値は一度だけランダム決定）
	_strafe_timer += delta
	if _strafe_timer > _next_strafe_change:
		_strafe_timer = 0.0
		_strafe_direction *= -1.0
		_next_strafe_change = randf_range(2.0, 4.0)

	if distance > max_range:
		# 遠すぎる → 接近
		return dir
	elif distance < keep_distance:
		# 近すぎる → 後退 + 横移動
		return (-dir + strafe * strafe_speed_factor).normalized()
	else:
		# 適正距離 → 横移動のみ
		return strafe

func reset() -> void:
	_strafe_direction = 1.0 if randf() > 0.5 else -1.0
	_strafe_timer = 0.0
	_next_strafe_change = randf_range(2.0, 4.0)
