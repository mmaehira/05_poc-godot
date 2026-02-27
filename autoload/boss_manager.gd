extends Node

## ボスバトル管理AutoLoad
## 定期的にボスを出現させ、撃破を管理

signal boss_spawned(boss: Node2D)
signal boss_defeated(boss: Node2D)
signal boss_health_changed(current: int, max: int)

const BOSS_SPAWN_INTERVAL: float = 180.0  # 3分

var current_boss: Node2D = null
var time_until_next_boss: float = 20.0  # 初回は20秒後（テスト用）
var boss_scenes: Array[PackedScene] = []

func _ready() -> void:
	_load_boss_scenes()

func _load_boss_scenes() -> void:
	boss_scenes = [
		preload("res://scenes/bosses/tank_boss.tscn"),
		preload("res://scenes/bosses/sniper_boss.tscn"),
		preload("res://scenes/bosses/swarm_boss.tscn")
	]

func _process(delta: float) -> void:
	if current_boss == null:
		time_until_next_boss -= delta
		if time_until_next_boss <= 0:
			spawn_boss()

## ボスを出現させる
func spawn_boss() -> void:
	var boss_scene = boss_scenes.pick_random()
	current_boss = boss_scene.instantiate()

	# 画面端からランダムに登場
	var spawn_position = _get_boss_spawn_position()
	current_boss.global_position = spawn_position

	var game_scene = get_tree().root.get_node_or_null("GameScene")
	if game_scene != null:
		game_scene.add_child(current_boss)
		current_boss.health_changed.connect(_on_boss_health_changed)
		current_boss.died.connect(_on_boss_defeated)

		boss_spawned.emit(current_boss)
		DebugConfig.log_info("BossManager", "ボス出現: %s" % current_boss.name)

		# ボス出現音
		AudioManager.play_sfx("explosion", -10.0)

## ボスのスポーン位置（画面端）
func _get_boss_spawn_position() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	var side = randi() % 4
	match side:
		0: return Vector2(randf() * viewport_size.x, -50)      # 上
		1: return Vector2(randf() * viewport_size.x, viewport_size.y + 50)  # 下
		2: return Vector2(-50, randf() * viewport_size.y)      # 左
		_: return Vector2(viewport_size.x + 50, randf() * viewport_size.y)  # 右

func _on_boss_health_changed(current: int, max: int) -> void:
	boss_health_changed.emit(current, max)

func _on_boss_defeated() -> void:
	DebugConfig.log_info("BossManager", "ボス撃破!")
	boss_defeated.emit(current_boss)
	current_boss = null
	time_until_next_boss = BOSS_SPAWN_INTERVAL

	# ボス撃破音
	AudioManager.play_sfx("levelup", -5.0)
