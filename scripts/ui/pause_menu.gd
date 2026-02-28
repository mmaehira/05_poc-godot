# pause_menu.gd
# ポーズメニュー画面
class_name PauseMenu extends CanvasLayer

signal resume_pressed()
signal title_pressed()

@onready var panel_container: PanelContainer = $PanelContainer
@onready var resume_button: Button = $PanelContainer/VBoxContainer/ResumeButton
@onready var title_button: Button = $PanelContainer/VBoxContainer/TitleButton


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	resume_button.pressed.connect(_on_resume_pressed)
	title_button.pressed.connect(_on_title_pressed)


## ポーズメニューを表示
func show_menu() -> void:
	visible = true


## ポーズメニューを非表示
func hide_menu() -> void:
	visible = false


## Escapeキーでアンポーズ（PROCESS_MODE_ALWAYSで動作）
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if GameManager.current_state == GameManager.GameState.PAUSED:
			_on_resume_pressed()


func _on_resume_pressed() -> void:
	visible = false
	resume_pressed.emit()


func _on_title_pressed() -> void:
	visible = false
	title_pressed.emit()
