class_name HUD extends CanvasLayer

## HUDクラス
##
## 責務:
## - HP表示
## - レベル表示
## - 経験値バー表示
## - 生存時間表示

@onready var hp_label: Label = $MarginContainer/VBoxContainer/HPLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var exp_bar: ProgressBar = $MarginContainer/VBoxContainer/ExpBar
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel

## 生存時間カウント用
var game_time: float = 0.0
var is_counting: bool = false


func _ready() -> void:
	# LevelSystemのシグナル接続
	LevelSystem.level_up.connect(_on_level_up)
	LevelSystem.exp_changed.connect(_on_exp_changed)

	# GameManagerのシグナル接続
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_over)

	# 初期表示
	_update_level_display()
	_update_exp_bar()


func _process(delta: float) -> void:
	if is_counting and GameManager.current_state == GameManager.GameState.PLAYING:
		game_time += delta
		_update_time_display()


func update_hp(current_hp: int, max_hp: int) -> void:
	if hp_label == null:
		push_error("update_hp: hp_label is null")
		return

	hp_label.text = "HP: %d / %d" % [current_hp, max_hp]


func _on_level_up(new_level: int) -> void:
	_update_level_display()
	_update_exp_bar()


func _on_exp_changed(current_exp: int, next_level_exp: int) -> void:
	_update_exp_bar()


func _on_game_started() -> void:
	game_time = 0.0
	is_counting = true
	_update_level_display()
	_update_exp_bar()
	_update_time_display()


func _on_game_over() -> void:
	is_counting = false


func _update_level_display() -> void:
	if level_label == null:
		return
	level_label.text = "Level: %d" % LevelSystem.current_level


func _update_exp_bar() -> void:
	if exp_bar == null:
		return

	exp_bar.max_value = LevelSystem.next_level_exp
	exp_bar.value = LevelSystem.experience


func _update_time_display() -> void:
	if time_label == null:
		return

	var minutes = int(game_time) / 60
	var seconds = int(game_time) % 60
	time_label.text = "Time: %02d:%02d" % [minutes, seconds]
