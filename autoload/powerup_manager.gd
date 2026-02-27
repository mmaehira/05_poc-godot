extends Node

## パワーアップアイテム管理AutoLoad
## 定期的にパワーアップを出現させ、効果を管理

const POWERUP_SCENE = preload("res://scenes/items/powerup.tscn")
const SPAWN_INTERVAL: float = 45.0  # 45秒ごと

var spawn_timer: float = 10.0  # 初回は10秒後

enum PowerUpType {
	INVINCIBILITY,     # 無敵
	DOUBLE_DAMAGE,     # 攻撃力2倍
	SPEED_BOOST,       # 移動速度2倍
	MAGNET,            # 磁力強化
	SCREEN_CLEAR       # 画面クリア
}

func _process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_powerup()
		spawn_timer = SPAWN_INTERVAL

## パワーアップアイテムを生成
func spawn_powerup() -> void:
	var powerup = POWERUP_SCENE.instantiate()
	powerup.powerup_type = PowerUpType.values().pick_random()
	powerup.global_position = _get_random_position()

	var game_scene = get_tree().root.get_node_or_null("GameScene")
	if game_scene != null:
		game_scene.add_child(powerup)
		print("[PowerUpManager] パワーアップ出現: %s at %s" % [PowerUpType.keys()[powerup.powerup_type], powerup.global_position])
	else:
		print("[PowerUpManager] ERROR: Game scene not found!")

## プレイヤーから離れたランダムな位置を取得
func _get_random_position() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	var player = get_tree().get_first_node_in_group("player")

	# プレイヤーから100px以上離れた位置
	var attempts = 10
	for i in range(attempts):
		var pos = Vector2(
			randf_range(50, viewport_size.x - 50),
			randf_range(50, viewport_size.y - 50)
		)
		if player == null or pos.distance_to(player.global_position) > 100:
			return pos

	# フォールバック: 画面中央
	return Vector2(viewport_size.x / 2, viewport_size.y / 2)

## パワーアップ効果を適用
func apply_powerup(type: PowerUpType, player: Node2D) -> void:
	DebugConfig.log_info("PowerUpManager", "パワーアップ取得: %s" % PowerUpType.keys()[type])

	match type:
		PowerUpType.INVINCIBILITY:
			player.add_powerup_effect("invincibility", 15.0)
		PowerUpType.DOUBLE_DAMAGE:
			player.add_powerup_effect("double_damage", 15.0)
		PowerUpType.SPEED_BOOST:
			player.add_powerup_effect("speed_boost", 12.0)
		PowerUpType.MAGNET:
			player.add_powerup_effect("magnet", 15.0)
		PowerUpType.SCREEN_CLEAR:
			_clear_screen()

## 画面上の全敵を撃破
func _clear_screen() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	DebugConfig.log_info("PowerUpManager", "画面クリア: %d体の敵を撃破" % enemies.size())

	for enemy in enemies:
		if enemy.has_method("take_damage"):
			enemy.take_damage(999999)

	# 画面クリアエフェクト（将来的に追加可能）
	AudioManager.play_sfx("explosion", -5.0)
