extends VBoxContainer

## パワーアップタイマー表示UI
## アクティブなパワーアップと残り時間を表示

@onready var player: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return

	# 既存の子要素をクリア
	for child in get_children():
		child.queue_free()

	# アクティブなパワーアップを表示
	if player.has("active_powerups"):
		for powerup_name in player.active_powerups.keys():
			var remaining_time = player.active_powerups[powerup_name]
			var label = Label.new()
			label.text = "%s: %.1fs" % [_get_powerup_display_name(powerup_name), remaining_time]
			label.modulate = _get_powerup_color(powerup_name)
			add_child(label)

## パワーアップの表示名を取得
func _get_powerup_display_name(powerup_name: String) -> String:
	match powerup_name:
		"invincibility": return "無敵"
		"double_damage": return "攻撃x2"
		"speed_boost": return "速度x2"
		"magnet": return "磁力x3"
		_: return powerup_name

## パワーアップの色を取得
func _get_powerup_color(powerup_name: String) -> Color:
	match powerup_name:
		"invincibility": return Color.YELLOW
		"double_damage": return Color.RED
		"speed_boost": return Color.CYAN
		"magnet": return Color.GREEN
		_: return Color.WHITE
