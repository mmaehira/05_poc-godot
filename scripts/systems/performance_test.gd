extends Node

## パフォーマンステスト用スクリプト
##
## 使用方法:
## 1. このスクリプトをGameSceneに追加
## 2. ゲームを実行
## 3. コンソールでメトリクスを確認

## テスト時間（秒）
const TEST_DURATION: float = 30.0

## メトリクス収集間隔（秒）
const METRICS_INTERVAL: float = 1.0

## テスト開始時刻
var test_start_time: float = 0.0
var metrics_timer: float = 0.0

## メトリクス
var fps_samples: Array[float] = []
var enemy_count_samples: Array[int] = []
var projectile_count_samples: Array[int] = []
var exp_orb_count_samples: Array[int] = []

var is_testing: bool = false


func _ready() -> void:
	print("\n=== パフォーマンステスト開始 ===")
	print("目標: 敵100体、弾丸300発")
	print("テスト時間: %.0f秒" % TEST_DURATION)
	print("=========================================")

	# アップグレード画面が表示されたら自動的にスキップ
	GameManager.state_changed.connect(_on_game_state_changed)


func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	# テスト中にアップグレード状態になったら即座にPLAYINGに戻す
	if is_testing and new_state == GameManager.GameState.UPGRADE:
		await get_tree().create_timer(0.1).timeout
		GameManager.change_state(GameManager.GameState.PLAYING)


func start_test() -> void:
	if is_testing:
		return

	is_testing = true
	test_start_time = Time.get_ticks_msec() / 1000.0
	metrics_timer = 0.0

	fps_samples.clear()
	enemy_count_samples.clear()
	projectile_count_samples.clear()
	exp_orb_count_samples.clear()

	# パフォーマンステスト用の高速射撃武器を追加
	_add_performance_test_weapons()

	print("\n[テスト開始] %.2fs" % test_start_time)


func _add_performance_test_weapons() -> void:
	# プレイヤーの取得
	var game_scene = get_tree().root.get_node_or_null("Game")
	if game_scene == null:
		push_error("Game scene not found")
		return

	var player = game_scene.get_node_or_null("Player")
	if player == null:
		push_error("Player not found")
		return

	var weapon_manager = player.get_node_or_null("WeaponManager")
	if weapon_manager == null:
		push_error("WeaponManager not found")
		return

	# 高速射撃武器をロードして追加
	var rapid_fire_weapon = load("res://resources/weapons/performance_test_rapid_fire.tres")
	if rapid_fire_weapon != null:
		weapon_manager.add_weapon(rapid_fire_weapon)
		print("パフォーマンステスト用武器を追加しました")


func _process(delta: float) -> void:
	if not is_testing:
		# ゲーム開始後に自動的にテスト開始
		if GameManager.current_state == GameManager.GameState.PLAYING:
			start_test()
		return

	var current_time = Time.get_ticks_msec() / 1000.0
	var elapsed = current_time - test_start_time

	# テスト時間終了
	if elapsed >= TEST_DURATION:
		_finish_test()
		return

	# メトリクス収集
	metrics_timer += delta
	if metrics_timer >= METRICS_INTERVAL:
		_collect_metrics()
		metrics_timer = 0.0


func _collect_metrics() -> void:
	# FPS
	var fps = Engine.get_frames_per_second()
	fps_samples.append(fps)

	# オブジェクト数
	var enemy_count = _get_total_active_enemies()
	var projectile_count = PoolManager.active_projectiles.size()
	var exp_orb_count = PoolManager.active_exp_orbs.size()

	enemy_count_samples.append(enemy_count)
	projectile_count_samples.append(projectile_count)
	exp_orb_count_samples.append(exp_orb_count)

	# リアルタイム表示
	var elapsed = (Time.get_ticks_msec() / 1000.0) - test_start_time
	print("[%.1fs] FPS: %d | 敵: %d | 弾: %d | オーブ: %d" % [
		elapsed,
		fps,
		enemy_count,
		projectile_count,
		exp_orb_count
	])


func _get_total_active_enemies() -> int:
	var total = 0
	for scene_path in PoolManager.active_enemies.keys():
		total += PoolManager.active_enemies[scene_path].size()
	return total


func _finish_test() -> void:
	is_testing = false

	print("\n=========================================")
	print("=== パフォーマンステスト完了 ===")
	print("=========================================")

	# 統計計算
	if fps_samples.is_empty():
		print("エラー: データが収集されませんでした")
		return

	var avg_fps = _calculate_average(fps_samples)
	var min_fps = _calculate_min(fps_samples)
	var max_fps = _calculate_max(fps_samples)

	var avg_enemies = _calculate_average_int(enemy_count_samples)
	var max_enemies = _calculate_max_int(enemy_count_samples)

	var avg_projectiles = _calculate_average_int(projectile_count_samples)
	var max_projectiles = _calculate_max_int(projectile_count_samples)

	var avg_exp_orbs = _calculate_average_int(exp_orb_count_samples)
	var max_exp_orbs = _calculate_max_int(exp_orb_count_samples)

	# 結果表示
	print("\n【FPS】")
	print("  平均: %.1f FPS" % avg_fps)
	print("  最小: %.1f FPS" % min_fps)
	print("  最大: %.1f FPS" % max_fps)

	print("\n【敵】")
	print("  平均: %d 体" % avg_enemies)
	print("  最大: %d 体" % max_enemies)
	print("  目標: 100体 -> %s" % ("達成" if max_enemies >= 100 else "未達成"))

	print("\n【弾丸】")
	print("  平均: %d 発" % avg_projectiles)
	print("  最大: %d 発" % max_projectiles)
	print("  目標: 300発 -> %s" % ("達成" if max_projectiles >= 300 else "未達成"))

	print("\n【経験値オーブ】")
	print("  平均: %d 個" % avg_exp_orbs)
	print("  最大: %d 個" % max_exp_orbs)

	print("\n【総合評価】")
	var fps_ok = min_fps >= 30.0
	var enemies_ok = max_enemies >= 100
	var projectiles_ok = max_projectiles >= 300

	print("  FPS 30以上: %s (最小%.1f FPS)" % ["✅" if fps_ok else "❌", min_fps])
	print("  敵100体: %s (最大%d体)" % ["✅" if enemies_ok else "❌", max_enemies])
	print("  弾丸300発: %s (最大%d発)" % ["✅" if projectiles_ok else "❌", max_projectiles])

	if fps_ok and enemies_ok and projectiles_ok:
		print("\n パフォーマンステスト合格！")
	else:
		print("\n パフォーマンステスト不合格")

	print("=========================================\n")


func _calculate_average(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var sum = 0.0
	for val in arr:
		sum += val
	return sum / arr.size()


func _calculate_min(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var min_val = arr[0]
	for val in arr:
		if val < min_val:
			min_val = val
	return min_val


func _calculate_max(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var max_val = arr[0]
	for val in arr:
		if val > max_val:
			max_val = val
	return max_val


func _calculate_average_int(arr: Array[int]) -> int:
	if arr.is_empty():
		return 0
	var sum = 0
	for val in arr:
		sum += val
	return sum / arr.size()


func _calculate_max_int(arr: Array[int]) -> int:
	if arr.is_empty():
		return 0
	var max_val = arr[0]
	for val in arr:
		if val > max_val:
			max_val = val
	return max_val
