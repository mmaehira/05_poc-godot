extends "res://scripts/bosses/boss.gd"

## スウォーム型ボス
## 中耐久、低速、敵を召喚

var summon_timer: float = 0.0
const SUMMON_INTERVAL: float = 5.0

func _ready() -> void:
	super._ready()
	max_health = 3000
	move_speed = 40.0
	damage = 15
	exp_value = 500

	visual.modulate = Color.PURPLE
	visual.custom_minimum_size = Vector2(50, 50)

	current_health = max_health

func _physics_process(delta: float) -> void:
	# ゆっくりプレイヤーに向かう
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()

	# 召喚パターン
	summon_timer -= delta
	if summon_timer <= 0:
		if current_phase == 1:
			_summon_minions(3)
		else:
			_summon_minions(5)
		summon_timer = SUMMON_INTERVAL

## フェーズ2移行時の変化
func _enter_phase_2() -> void:
	super._enter_phase_2()
	visual.modulate = Color.DARK_MAGENTA

## 敵を召喚
func _summon_minions(count: int) -> void:
	for i in range(count):
		var enemy = PoolManager.get_from_pool("basic_enemy")
		if enemy:
			var offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
			enemy.global_position = global_position + offset
			enemy.modulate = Color.MAGENTA  # 召喚された敵の色

	DebugConfig.log_debug("SwarmBoss", "%d体の敵を召喚!" % count)
	AudioManager.play_sfx("pickup", -8.0)  # 召喚音
