# game_over_screen.gd
# ゲームオーバー / ステージクリア結果画面
class_name GameOverScreen extends CanvasLayer

signal retry_pressed()
signal title_pressed()

@onready var panel_container: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var stats_container: VBoxContainer = $PanelContainer/VBoxContainer/StatsContainer
@onready var time_label: Label = $PanelContainer/VBoxContainer/StatsContainer/TimeLabel
@onready var level_label: Label = $PanelContainer/VBoxContainer/StatsContainer/LevelLabel
@onready var kills_label: Label = $PanelContainer/VBoxContainer/StatsContainer/KillsLabel
@onready var damage_dealt_label: Label = $PanelContainer/VBoxContainer/StatsContainer/DamageDealtLabel
@onready var damage_taken_label: Label = $PanelContainer/VBoxContainer/StatsContainer/DamageTakenLabel
@onready var retry_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/RetryButton
@onready var title_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/TitleButton


func _ready() -> void:
	# 初期状態は非表示
	visible = false

	# process_mode設定（PAUSED時も動作）
	process_mode = Node.PROCESS_MODE_ALWAYS

	# ボタンシグナル接続
	retry_button.pressed.connect(_on_retry_pressed)
	title_button.pressed.connect(_on_title_pressed)


## 結果画面を表示（クリア/ゲームオーバー共通）
func show_result(game_stats: GameStats, is_clear: bool) -> void:
	if game_stats == null:
		push_error("show_result: game_stats is null")
		return

	# タイトル文言を切り替え
	title_label.text = "ステージクリア！" if is_clear else "ゲームオーバー"

	# 統計データを表示
	_display_stats(game_stats)

	# 画面を表示
	visible = true


## 統計データを表示
func _display_stats(stats: GameStats) -> void:
	# 生存時間
	var minutes = int(stats.survival_time) / 60
	var seconds = int(stats.survival_time) % 60
	time_label.text = "生存時間: %02d:%02d" % [minutes, seconds]

	# 最終レベル
	level_label.text = "到達レベル: Lv%d" % stats.final_level

	# 撃破数
	kills_label.text = "撃破数: %d" % stats.kill_count

	# 与ダメージ
	damage_dealt_label.text = "与ダメージ: %d" % stats.total_damage_dealt

	# 被ダメージ
	damage_taken_label.text = "被ダメージ: %d" % stats.total_damage_taken


## リトライボタン押下
func _on_retry_pressed() -> void:
	visible = false
	retry_pressed.emit()


## タイトルボタン押下
func _on_title_pressed() -> void:
	visible = false
	title_pressed.emit()
