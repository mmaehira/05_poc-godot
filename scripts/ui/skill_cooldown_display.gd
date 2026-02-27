extends Control

## スキルクールダウン表示UI
## スキルアイコンとクールダウンゲージを表示（溜まっていくスタイル）

@onready var skill_icon: ColorRect = $SkillIcon
@onready var skill_label: Label = $SkillLabel
@onready var cooldown_bar: ProgressBar = $CooldownBar
@onready var remaining_time_label: Label = $RemainingTimeLabel
@onready var ready_label: Label = $ReadyLabel

var skill_manager: Node = null
var is_initialized: bool = false

func _ready() -> void:
	_try_initialize()
	# 初期状態では非表示
	if ready_label:
		ready_label.hide()
	if remaining_time_label:
		remaining_time_label.hide()

func _process(_delta: float) -> void:
	if not is_initialized:
		_try_initialize()
	else:
		_update_display()

func _try_initialize() -> void:
	if is_initialized:
		return

	var player = get_tree().get_first_node_in_group("player")
	if player:
		skill_manager = player.get_node_or_null("SkillManager")
		if skill_manager:
			skill_manager.skill_used.connect(_on_skill_used)

			# 初期表示
			_update_display()

			is_initialized = true

func _update_display() -> void:
	if not skill_manager:
		return

	# スキル名を常に更新
	var skill_name = skill_manager.SkillType.keys()[skill_manager.selected_skill]
	skill_label.text = "%s [SPACE]" % _get_skill_display_name(skill_name)

	# アイコンの色を更新（スキルごとに色分け）
	if skill_icon:
		skill_icon.color = _get_skill_color(skill_name)

	# ゲージを「溜まっていく」スタイルに変更
	var max_cd = skill_manager.skill_cooldowns[skill_manager.selected_skill]
	var remaining = skill_manager.cooldown_remaining

	cooldown_bar.max_value = 100.0  # パーセント表示
	if remaining > 0:
		# クールダウン中: 0%から100%に向かって溜まる
		var progress = ((max_cd - remaining) / max_cd) * 100.0
		cooldown_bar.value = progress

		# アイコンとラベルを暗くする
		skill_icon.modulate = Color(0.5, 0.5, 0.5)
		skill_label.modulate = Color(0.6, 0.6, 0.6)

		# 残り秒を表示
		if remaining_time_label:
			remaining_time_label.show()
			remaining_time_label.text = "%.1fs" % remaining

		if ready_label:
			ready_label.hide()
	else:
		# 準備完了: 100%
		cooldown_bar.value = 100.0

		# アイコンとラベルを通常の明るさに
		skill_icon.modulate = Color(1.0, 1.0, 1.0)
		skill_label.modulate = Color(1.0, 1.0, 0.3)  # 黄色で強調

		# 残り秒を非表示
		if remaining_time_label:
			remaining_time_label.hide()

		if ready_label:
			ready_label.show()

func _on_skill_used(skill_name: String) -> void:
	# スキル使用時の演出
	var tween = create_tween()
	tween.tween_property(skill_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(skill_label, "scale", Vector2(1.0, 1.0), 0.1)

## スキルの表示名を取得
func _get_skill_display_name(skill_name: String) -> String:
	match skill_name:
		"DASH": return "ダッシュ"
		"NOVA_BLAST": return "範囲攻撃"
		"SHIELD": return "シールド"
		"TIME_SLOW": return "時間減速"
		_: return skill_name

## スキルのアイコン色を取得（プレースホルダー）
func _get_skill_color(skill_name: String) -> Color:
	match skill_name:
		"DASH": return Color(0.2, 0.8, 1.0)  # 青系（高速移動）
		"NOVA_BLAST": return Color(1.0, 0.3, 0.2)  # 赤系（攻撃）
		"SHIELD": return Color(0.2, 1.0, 0.5)  # 緑系（防御）
		"TIME_SLOW": return Color(0.8, 0.2, 1.0)  # 紫系（時間操作）
		_: return Color(1.0, 1.0, 1.0)  # デフォルト白
