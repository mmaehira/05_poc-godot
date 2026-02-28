# scripts/ui/powerup_icon.gd
extends HBoxContainer

@onready var icon_label: Label = $IconLabel
@onready var timer_label: Label = $TimerLabel

var powerup_name: String = ""

func setup(name: String) -> void:
	powerup_name = name

	# アイコン表示（仮実装: 最初の2文字）
	icon_label.text = name.substr(0, 2).to_upper()

	# 色設定
	match powerup_name:
		"invincibility":
			modulate = Color.YELLOW
		"double_damage":
			modulate = Color.RED
		"speed_boost":
			modulate = Color.CYAN
		"magnet":
			modulate = Color.GREEN

func update_timer(remaining: float) -> void:
	timer_label.text = "%.1fs" % remaining

	# 残り2秒以下で点滅
	if remaining <= 2.0:
		modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.01)
	else:
		modulate.a = 1.0
