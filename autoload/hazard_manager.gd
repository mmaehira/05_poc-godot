extends Node

## 環境ハザード管理AutoLoad
## 定期的にハザードを出現させる

const HAZARD_SCENE = preload("res://scenes/hazards/hazard.tscn")
const SPAWN_INTERVAL: float = 20.0  # 20秒ごと

var spawn_timer: float = 15.0  # 初回は15秒後

enum HazardType {
	LAVA_POOL,         # 溶岩（毎秒10ダメージ、8秒持続）
	POISON_CLOUD,      # 毒の雲（毎秒5ダメージ、12秒持続）
	LIGHTNING_STRIKE,  # 落雷（一撃100ダメージ）
	ICE_PATCH          # 氷床（移動速度50%減少、10秒持続）
}

func _process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_hazard()
		spawn_timer = SPAWN_INTERVAL

## ハザードを生成
func spawn_hazard() -> void:
	var hazard = HAZARD_SCENE.instantiate()
	hazard.hazard_type = HazardType.values().pick_random()
	hazard.global_position = _get_safe_spawn_position()

	var game_scene = get_tree().root.get_node_or_null("GameScene")
	if game_scene != null:
		game_scene.add_child(hazard)
		print("[HazardManager] ハザード出現: %s at %s" % [HazardType.keys()[hazard.hazard_type], hazard.global_position])
	else:
		print("[HazardManager] ERROR: Game scene not found!")

## プレイヤーから離れた安全な位置を取得
func _get_safe_spawn_position() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	var player = get_tree().get_first_node_in_group("player")

	# プレイヤーから100px以上離れた位置
	for i in range(10):
		var pos = Vector2(
			randf_range(100, viewport_size.x - 100),
			randf_range(100, viewport_size.y - 100)
		)
		if player == null or pos.distance_to(player.global_position) > 100:
			return pos

	# フォールバック: 画面中央
	return Vector2(viewport_size.x / 2, viewport_size.y / 2)
