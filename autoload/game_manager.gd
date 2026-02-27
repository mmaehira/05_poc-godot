## GameManager Autoload
##
## 責務:
## - ゲーム状態の一元管理
## - ポーズ制御の唯一の実行者（get_tree().pausedの変更権限）
## - シーン遷移制御
## - ゲーム統計の管理（GameStats Resource）
##
## 重要:
## - 純粋Autoloadとして使用（シーンに配置しない）
## - ポーズ制御はこのクラスのみが実行
## - game_statsはGameStats Resource（Dictionaryではない）
extends Node

const GameStats = preload("res://resources/game_stats.gd")

## ゲーム状態の定義
enum GameState {
	TITLE,      ## タイトル画面
	PLAYING,    ## プレイ中
	PAUSED,     ## ポーズ中
	UPGRADE,    ## レベルアップ選択中
	GAME_OVER   ## ゲームオーバー
}

## ゲーム状態変更時に発火
signal state_changed(new_state: GameState)
## ゲーム開始時に発火
signal game_started()
## ゲームオーバー時に発火
signal game_over()

## 現在のゲーム状態
var current_state: GameState = GameState.TITLE
## ゲーム統計情報（GameStats Resource）
var game_stats: GameStats = null


func _ready() -> void:
	# Autoload初期化時はTITLE状態から開始
	current_state = GameState.TITLE


## ゲーム状態を変更する
##
## ポーズ制御を自動的に実行する。
## UPGRADE/PAUSED/GAME_OVERではゲーム一時停止、PLAYINGで再開。
##
## @param new_state: 変更先のGameState
func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	state_changed.emit(new_state)

	# ポーズ制御（このクラスのみが実行する唯一の権限者）
	match new_state:
		GameState.UPGRADE, GameState.PAUSED, GameState.GAME_OVER:
			get_tree().paused = true
		GameState.PLAYING:
			get_tree().paused = false
		GameState.TITLE:
			get_tree().paused = false


## ゲームを開始する
##
## GameStats Resourceを新規作成し、LevelSystemをリセットする。
## PoolManagerのクリアも実行。
func start_game() -> void:
	# GameStats Resource新規作成
	game_stats = GameStats.new()
	game_stats.start_time = Time.get_ticks_msec()

	# LevelSystemのリセット（重要: 経験値・レベルの初期化）
	if LevelSystem:
		LevelSystem.reset()
	else:
		push_error("GameManager.start_game: LevelSystemが見つかりません")

	# PoolManagerのクリア
	if PoolManager:
		PoolManager.clear_all_active()
	else:
		push_warning("GameManager.start_game: PoolManagerが見つかりません")

	# 状態変更とシグナル発火
	change_state(GameState.PLAYING)
	game_started.emit()


## ゲームを終了する
##
## GameStatsの終了時刻・生存時間を記録し、GAME_OVER状態に遷移。
func end_game() -> void:
	if game_stats == null:
		push_warning("GameManager.end_game: game_statsがnullです")
		game_stats = GameStats.new()

	# 終了時刻と生存時間を記録
	game_stats.end_time = Time.get_ticks_msec()
	game_stats.survival_time = (game_stats.end_time - game_stats.start_time) / 1000.0

	# 最終レベルを記録
	if LevelSystem:
		game_stats.final_level = LevelSystem.current_level

	# 状態変更とシグナル発火
	change_state(GameState.GAME_OVER)
	game_over.emit()


## ゲームを一時停止する
##
## 内部的にchange_state(PAUSED)を呼び出す。
func pause_game() -> void:
	change_state(GameState.PAUSED)


## ゲームを再開する
##
## 内部的にchange_state(PLAYING)を呼び出す。
func resume_game() -> void:
	change_state(GameState.PLAYING)
