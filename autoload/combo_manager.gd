extends Node

## コンボシステムを管理するAutoLoad
## 連続撃破でコンボが増加し、経験値にボーナスが付く

signal combo_increased(combo: int)
signal combo_broken(final_combo: int)
signal combo_multiplier_changed(multiplier: float)

var current_combo: int = 0
var combo_timer: float = 0.0
const COMBO_TIMEOUT: float = 3.0

func _process(delta: float) -> void:
	if current_combo > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			break_combo()

## 敵撃破時にコンボを加算
func add_combo() -> void:
	current_combo += 1
	combo_timer = COMBO_TIMEOUT
	combo_increased.emit(current_combo)

	var multiplier = get_exp_multiplier()
	combo_multiplier_changed.emit(multiplier)

	DebugConfig.log_debug("ComboManager", "コンボ: %d (倍率: %.1fx)" % [current_combo, multiplier])

## コンボが途切れる
func break_combo() -> void:
	if current_combo == 0:
		return

	var final = current_combo
	current_combo = 0
	combo_timer = 0.0
	combo_broken.emit(final)

	DebugConfig.log_info("ComboManager", "コンボ終了: %d" % final)

## コンボ数に応じた経験値倍率を取得
func get_exp_multiplier() -> float:
	if current_combo >= 100:
		return 2.0
	elif current_combo >= 50:
		return 1.5
	elif current_combo >= 20:
		return 1.2
	elif current_combo >= 10:
		return 1.1
	else:
		return 1.0

## 現在のコンボ数を取得
func get_combo() -> int:
	return current_combo

## 残り時間を取得
func get_time_remaining() -> float:
	return combo_timer

## コンボタイムアウトまでの進行度（0.0-1.0）
func get_timer_progress() -> float:
	if current_combo == 0:
		return 0.0
	return combo_timer / COMBO_TIMEOUT
