class_name EnemySpawner extends Node

## EnemySpawnerクラス
##
## 責務:
## - 敵の定期的なスポーン
## - 難易度曲線による調整
## - 重み付き確率で複数種類の敵を選択

const BASIC_ENEMY_SCENE: String = "res://scenes/enemies/basic_enemy.tscn"
const STRONG_ENEMY_SCENE: String = "res://scenes/enemies/strong_enemy.tscn"
const HEAVY_ENEMY_SCENE: String = "res://scenes/enemies/heavy_enemy.tscn"
const FAST_ENEMY_SCENE: String = "res://scenes/enemies/fast_enemy.tscn"

## 敵のスポーンテーブル（scene_path, weight）
## weight: 出現確率の重み（合計100）
var enemy_spawn_table: Array = []

@export var base_spawn_interval: float = 1.5
@export var spawn_radius: float = 600.0
@export var max_game_time: float = 900.0  # 15分

## パフォーマンステストモード（敵を高頻度でスポーン）
@export var performance_test_mode: bool = false

var player: Node = null
var game_start_time: int = 0
var _spawn_timer: float = 0.0

func initialize(target_player: Node) -> void:
	if target_player == null:
		push_error("EnemySpawner.initialize: target_player is null")
		return

	player = target_player
	game_start_time = Time.get_ticks_msec()
	_setup_spawn_table()

func _ready() -> void:
	# GameSceneから初期化される
	pass

func _process(delta: float) -> void:
	if player == null:
		print("EnemySpawner: player is null")
		return

	if GameManager.current_state != GameManager.GameState.PLAYING:
		# デバッグ: 最初の1回だけ状態を表示
		if _spawn_timer == 0.0:
			print("EnemySpawner: Not PLAYING state (current: %d)" % GameManager.current_state)
		return

	_spawn_timer += delta

	var current_interval = _get_current_spawn_interval()

	if _spawn_timer >= current_interval:
		_spawn_enemy()
		_spawn_timer = 0.0

func _spawn_enemy() -> void:
	var scene_path = _choose_enemy_scene()
	var spawn_pos = _get_spawn_position()

	var enemy = PoolManager.spawn_enemy(scene_path, spawn_pos)
	if enemy != null and enemy.has_method("initialize"):
		enemy.initialize(spawn_pos, player)
		# デバッグログは無効化（パフォーマンステスト用）
		# print("EnemySpawner: Spawned %s at %s" % [scene_path.get_file(), spawn_pos])
	elif not performance_test_mode:
		print("EnemySpawner: Failed to spawn enemy")

func _get_spawn_position() -> Vector2:
	if player == null:
		return Vector2.ZERO

	# プレイヤーの周囲、画面外にスポーン
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	return player.global_position + offset

func _choose_enemy_scene() -> String:
	var progress = _get_game_progress()
	_update_spawn_table_by_progress(progress)

	# 重み付き確率抽選
	var total_weight = 0
	for entry in enemy_spawn_table:
		total_weight += entry["weight"]

	var rand_value = randf() * total_weight
	var accumulated_weight = 0

	for entry in enemy_spawn_table:
		accumulated_weight += entry["weight"]
		if rand_value < accumulated_weight:
			return entry["scene"]

	# フォールバック（通常は到達しない）
	return BASIC_ENEMY_SCENE

func _get_game_progress() -> float:
	var elapsed = (Time.get_ticks_msec() - game_start_time) / 1000.0
	return clampf(elapsed / max_game_time, 0.0, 1.0)

func _get_current_spawn_interval() -> float:
	# パフォーマンステストモード: 高頻度スポーン
	if performance_test_mode:
		return 0.1  # 0.1秒間隔で大量スポーン

	var progress = _get_game_progress()

	# 難易度曲線: 時間経過で間隔短縮（最小0.5秒）
	var difficulty_multiplier = 1.0 - (progress * 0.75)  # 1.0 → 0.25
	var interval = base_spawn_interval * difficulty_multiplier

	return max(0.5, interval)


## スポーンテーブルを初期化
func _setup_spawn_table() -> void:
	enemy_spawn_table = [
		{"scene": BASIC_ENEMY_SCENE, "weight": 50},   # 基本敵: 50%
		{"scene": FAST_ENEMY_SCENE, "weight": 25},    # 高速敵: 25%
		{"scene": HEAVY_ENEMY_SCENE, "weight": 10},   # 重装敵: 10%
		{"scene": STRONG_ENEMY_SCENE, "weight": 15},  # 強敵: 15%
	]


## ゲーム進行度に応じてスポーンテーブルを動的に調整
func _update_spawn_table_by_progress(progress: float) -> void:
	# 進行度0.0-1.0で重みを調整
	# 序盤: Basic/Fast中心
	# 中盤: 全種類バランス良く
	# 終盤: Heavy/Strong増加

	if progress < 0.3:
		# 序盤（0-30%）: Basic 60%, Fast 30%, Heavy 5%, Strong 5%
		enemy_spawn_table[0]["weight"] = 60  # Basic
		enemy_spawn_table[1]["weight"] = 30  # Fast
		enemy_spawn_table[2]["weight"] = 5   # Heavy
		enemy_spawn_table[3]["weight"] = 5   # Strong
	elif progress < 0.6:
		# 中盤（30-60%）: Basic 45%, Fast 25%, Heavy 15%, Strong 15%
		enemy_spawn_table[0]["weight"] = 45
		enemy_spawn_table[1]["weight"] = 25
		enemy_spawn_table[2]["weight"] = 15
		enemy_spawn_table[3]["weight"] = 15
	else:
		# 終盤（60-100%）: Basic 30%, Fast 20%, Heavy 25%, Strong 25%
		enemy_spawn_table[0]["weight"] = 30
		enemy_spawn_table[1]["weight"] = 20
		enemy_spawn_table[2]["weight"] = 25
		enemy_spawn_table[3]["weight"] = 25
