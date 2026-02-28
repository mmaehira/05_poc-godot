class_name AIRush extends AIController

## 突進AI（Charger用）
##
## 状態遷移:
## APPROACH → CHARGE → RUSHING → COOLDOWN → APPROACH

enum State { APPROACH, CHARGE, RUSHING, COOLDOWN }

@export var rush_trigger_distance: float = 150.0
@export var rush_speed: float = 350.0
@export var normal_speed: float = 70.0
@export var charge_duration: float = 0.3
@export var rush_duration: float = 0.4
@export var cooldown_duration: float = 1.5

var _state: State = State.APPROACH
var _timer: float = 0.0
var _rush_direction: Vector2 = Vector2.ZERO
var _original_speed: float = 0.0

func calculate_direction(enemy: Node, player: Node, delta: float) -> Vector2:
	var to_player = (player.global_position - enemy.global_position)
	var distance = to_player.length()
	var dir = to_player.normalized()

	match _state:
		State.APPROACH:
			if distance < rush_trigger_distance:
				_state = State.CHARGE
				_timer = 0.0
				_rush_direction = dir
				_original_speed = enemy.speed
			return dir

		State.CHARGE:
			_timer += delta
			# 予備動作中は停止（ビジュアルで予告）
			if _timer >= charge_duration:
				_state = State.RUSHING
				_timer = 0.0
				enemy.speed = rush_speed
			return Vector2.ZERO

		State.RUSHING:
			_timer += delta
			if _timer >= rush_duration:
				_state = State.COOLDOWN
				_timer = 0.0
				enemy.speed = _original_speed
			return _rush_direction  # 方向固定で直進

		State.COOLDOWN:
			_timer += delta
			if _timer >= cooldown_duration:
				_state = State.APPROACH
			return Vector2.ZERO  # クールダウン中は停止

	return dir

func reset() -> void:
	_state = State.APPROACH
	_timer = 0.0
	_rush_direction = Vector2.ZERO
