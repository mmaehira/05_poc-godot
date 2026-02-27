extends Control

## コンボ表示UI
## コンボ数、タイマーゲージ、色変化を表示

@onready var combo_label: Label = $ComboLabel
@onready var timer_bar: ProgressBar = $TimerBar

func _ready() -> void:
	ComboManager.combo_increased.connect(_on_combo_increased)
	ComboManager.combo_broken.connect(_on_combo_broken)
	hide()

func _process(_delta: float) -> void:
	if ComboManager.get_combo() > 0:
		# タイマーバーの更新
		timer_bar.value = ComboManager.get_timer_progress() * 100.0

		# コンボ数の更新
		var combo = ComboManager.get_combo()
		var multiplier = ComboManager.get_exp_multiplier()
		combo_label.text = "%d COMBO! (x%.1f)" % [combo, multiplier]

		# コンボ数に応じた色変化
		_update_color(combo)

func _on_combo_increased(combo: int) -> void:
	if combo == 1:
		show()

	# ポップアップアニメーション
	var tween = create_tween()
	tween.tween_property(combo_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.1)

	# コンボ音（コンボ数に応じて高くなる）
	var frequency = 600.0 + (combo * 5.0)
	frequency = min(frequency, 1200.0)  # 最大1200Hz
	# 既存のSEを使用（将来的に専用音を追加可能）

func _on_combo_broken(final_combo: int) -> void:
	DebugConfig.log_info("ComboDisplay", "コンボ終了: %d" % final_combo)

	# フェードアウト演出
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished

	hide()
	modulate.a = 1.0

func _update_color(combo: int) -> void:
	if combo >= 50:
		# 虹色エフェクト（時間で変化）
		var hue = fmod(Time.get_ticks_msec() / 1000.0, 1.0)
		combo_label.modulate = Color.from_hsv(hue, 1.0, 1.0)
	elif combo >= 10:
		# 金色
		combo_label.modulate = Color.GOLD
	else:
		# 白色
		combo_label.modulate = Color.WHITE
