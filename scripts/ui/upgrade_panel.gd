# upgrade_panel.gd
# レベルアップ時のアップグレード選択UI
class_name UpgradePanel extends CanvasLayer

const UpgradeGenerator = preload("res://scripts/systems/upgrade_generator.gd")

signal upgrade_selected(option: UpgradeGenerator.UpgradeOption)

## アップグレード選択肢（3つ）
var current_options: Array[UpgradeGenerator.UpgradeOption] = []

@onready var panel_container: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var option1_button: Button = $PanelContainer/VBoxContainer/Option1Button
@onready var option2_button: Button = $PanelContainer/VBoxContainer/Option2Button
@onready var option3_button: Button = $PanelContainer/VBoxContainer/Option3Button


func _ready() -> void:
	# 初期状態は非表示
	visible = false

	# process_mode設定（PAUSED時も動作）
	process_mode = Node.PROCESS_MODE_ALWAYS

	# ボタンシグナル接続
	option1_button.pressed.connect(_on_option1_pressed)
	option2_button.pressed.connect(_on_option2_pressed)
	option3_button.pressed.connect(_on_option3_pressed)


## 選択肢を表示
func show_options(options: Array[UpgradeGenerator.UpgradeOption]) -> void:
	if options.size() != 3:
		push_error("show_options: options.size() != 3")
		return

	current_options = options

	# ボタンテキストを設定
	_update_button_text(option1_button, options[0])
	_update_button_text(option2_button, options[1])
	_update_button_text(option3_button, options[2])

	# パネルを表示
	visible = true


## ボタンテキストを更新
func _update_button_text(button: Button, option: UpgradeGenerator.UpgradeOption) -> void:
	var rarity_text = ""
	match option.rarity:
		UpgradeGenerator.Rarity.NORMAL:
			rarity_text = "[通常]"
		UpgradeGenerator.Rarity.ENHANCED:
			rarity_text = "[強化]"
		UpgradeGenerator.Rarity.RARE:
			rarity_text = "[希少]"

	button.text = "%s %s\n%s" % [rarity_text, option.display_name, option.description]


## 選択肢1が選ばれた
func _on_option1_pressed() -> void:
	_select_option(0)


## 選択肢2が選ばれた
func _on_option2_pressed() -> void:
	_select_option(1)


## 選択肢3が選ばれた
func _on_option3_pressed() -> void:
	_select_option(2)


## 選択肢を確定
func _select_option(index: int) -> void:
	if index < 0 or index >= current_options.size():
		push_error("select_option: invalid index %d" % index)
		return

	var selected_option = current_options[index]
	upgrade_selected.emit(selected_option)

	# パネルを非表示
	visible = false
	current_options.clear()
