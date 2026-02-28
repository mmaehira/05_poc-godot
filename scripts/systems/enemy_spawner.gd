class_name EnemySpawner extends Node

## EnemySpawnerクラス
##
## 責務:
## - 敵の定期的なスポーン
## - 難易度曲線による調整
## - 重み付き確率で6種類の敵を選択
## - Swarmはグループスポーン対応

const CHARGER_SCENE: String = "res://scenes/enemies/charger_enemy.tscn"
const SWARM_SCENE: String = "res://scenes/enemies/swarm_enemy.tscn"
const TANK_SCENE: String = "res://scenes/enemies/tank_enemy.tscn"
const SHOOTER_SCENE: String = "res://scenes/enemies/shooter_enemy.tscn"
const BOMBER_SCENE: String = "res://scenes/enemies/bomber_enemy.tscn"
const SNIPER_SCENE: String = "res://scenes/enemies/sniper_enemy.tscn"

## 敵のスポーンテーブル（scene_path, weight）
## weight: 出現確率の重み（合計100）
var enemy_spawn_table: Array = []

@export var base_spawn_interval: float = 1.5
@export var spawn_radius: float = 600.0
@export var max_game_time: float = 900.0  # 15分

## パフォーマンステストモード（敵を高頻度でスポーン）
@export var performance_test_mode: bool = false

## Swarmのグループスポーン数
const SWARM_GROUP_MIN: int = 5
const SWARM_GROUP_MAX: int = 8

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

## ゲーム再開時にスポーナー状態をリセット
func reset_timer() -> void:
	game_start_time = Time.get_ticks_msec()
	_spawn_timer = 0.0
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

	# Swarmはグループスポーン
	if scene_path == SWARM_SCENE:
		_spawn_swarm_group()
		return

	var spawn_pos = _get_spawn_position()

	var enemy = PoolManager.spawn_enemy(scene_path, spawn_pos)
	if enemy != null and enemy.has_method("initialize"):
		enemy.initialize(spawn_pos, player)
	elif not performance_test_mode:
		print("EnemySpawner: Failed to spawn enemy")

## Swarmをグループスポーン（5-8体同時）
func _spawn_swarm_group() -> void:
	var count = randi_range(SWARM_GROUP_MIN, SWARM_GROUP_MAX)
	var center_pos = _get_spawn_position()

	for i in range(count):
		# グループ内でやや散らばらせる
		var offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
		var spawn_pos = center_pos + offset

		var enemy = PoolManager.spawn_enemy(SWARM_SCENE, spawn_pos)
		if enemy != null and enemy.has_method("initialize"):
			enemy.initialize(spawn_pos, player)

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

	# フォールバック
	return SWARM_SCENE

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
		{"scene": SWARM_SCENE, "weight": 50},     # Swarm: 50%
		{"scene": CHARGER_SCENE, "weight": 20},    # Charger: 20%
		{"scene": TANK_SCENE, "weight": 5},        # Tank: 5%
		{"scene": SHOOTER_SCENE, "weight": 20},    # Shooter: 20%
		{"scene": BOMBER_SCENE, "weight": 5},      # Bomber: 5%
		{"scene": SNIPER_SCENE, "weight": 0},      # Sniper: 0%（序盤は出ない）
	]


## ゲーム進行度に応じてスポーンテーブルを動的に調整
func _update_spawn_table_by_progress(progress: float) -> void:
	# design.md のスポーンテーブルに準拠
	# 序盤(0-25%): Swarm50, Charger20, Tank5, Shooter20, Bomber5, Sniper0
	# 中盤前半(25-50%): Swarm35, Charger20, Tank10, Shooter20, Bomber10, Sniper5
	# 中盤後半(50-75%): Swarm25, Charger15, Tank15, Shooter20, Bomber15, Sniper10
	# 終盤(75-100%): Swarm20, Charger15, Tank15, Shooter20, Bomber15, Sniper15

	if progress < 0.25:
		# 序盤（0-25%）
		enemy_spawn_table[0]["weight"] = 50  # Swarm
		enemy_spawn_table[1]["weight"] = 20  # Charger
		enemy_spawn_table[2]["weight"] = 5   # Tank
		enemy_spawn_table[3]["weight"] = 20  # Shooter
		enemy_spawn_table[4]["weight"] = 5   # Bomber
		enemy_spawn_table[5]["weight"] = 0   # Sniper
	elif progress < 0.50:
		# 中盤前半（25-50%）
		enemy_spawn_table[0]["weight"] = 35  # Swarm
		enemy_spawn_table[1]["weight"] = 20  # Charger
		enemy_spawn_table[2]["weight"] = 10  # Tank
		enemy_spawn_table[3]["weight"] = 20  # Shooter
		enemy_spawn_table[4]["weight"] = 10  # Bomber
		enemy_spawn_table[5]["weight"] = 5   # Sniper
	elif progress < 0.75:
		# 中盤後半（50-75%）
		enemy_spawn_table[0]["weight"] = 25  # Swarm
		enemy_spawn_table[1]["weight"] = 15  # Charger
		enemy_spawn_table[2]["weight"] = 15  # Tank
		enemy_spawn_table[3]["weight"] = 20  # Shooter
		enemy_spawn_table[4]["weight"] = 15  # Bomber
		enemy_spawn_table[5]["weight"] = 10  # Sniper
	else:
		# 終盤（75-100%）
		enemy_spawn_table[0]["weight"] = 20  # Swarm
		enemy_spawn_table[1]["weight"] = 15  # Charger
		enemy_spawn_table[2]["weight"] = 15  # Tank
		enemy_spawn_table[3]["weight"] = 20  # Shooter
		enemy_spawn_table[4]["weight"] = 15  # Bomber
		enemy_spawn_table[5]["weight"] = 15  # Sniper
