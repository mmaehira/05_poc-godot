# title_screen.gd
# タイトル画面
class_name TitleScreen extends CanvasLayer

signal start_pressed()
signal quit_pressed()

@onready var panel_container: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $PanelContainer/VBoxContainer/SubtitleLabel
@onready var start_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/StartButton
@onready var quit_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/QuitButton


func _ready() -> void:
	# 初期状態は表示
	visible = true

	# process_mode設定（PAUSED時も動作）
	process_mode = Node.PROCESS_MODE_ALWAYS

	# ボタンシグナル接続
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


## タイトル画面を表示
func show_title() -> void:
	visible = true
	panel_container.visible = true


## タイトル画面を非表示
func hide_title() -> void:
	visible = false
	panel_container.visible = false


## スタートボタン押下
func _on_start_pressed() -> void:
	start_pressed.emit()


## 終了ボタン押下
func _on_quit_pressed() -> void:
	quit_pressed.emit()
