extends "res://scripts/bosses/boss.gd"

## スナイパー型ボス
## 中耐久、高速、遠距離から狙撃

var attack_timer: float = 0.0
const ATTACK_INTERVAL: float = 2.0

func _ready() -> void:
	super._ready()
	max_health = 2000
	move_speed = 80.0
	damage = 50
	exp_value = 500

	visual.modulate = Color.DARK_GREEN
	visual.custom_minimum_size = Vector2(40, 40)

	current_health = max_health

func _physics_process(delta: float) -> void:
	# プレイヤーから距離を保つ
	if player and is_instance_valid(player):
		var direction = (global_position - player.global_position).normalized()
		var distance = global_position.distance_to(player.global_position)

		if distance < 300:
			velocity = direction * move_speed  # 離れる
		elif distance > 500:
			velocity = -direction * move_speed  # 近づく
		else:
			velocity = Vector2.ZERO

		move_and_slide()

	# 攻撃パターン
	attack_timer -= delta
	if attack_timer <= 0:
		if current_phase == 1:
			_attack_snipe()
		else:
			_attack_triple_snipe()
		attack_timer = ATTACK_INTERVAL

## フェーズ2移行時の変化
func _enter_phase_2() -> void:
	super._enter_phase_2()
	visual.modulate = Color.LIME_GREEN

## 狙撃攻撃
func _attack_snipe() -> void:
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		_spawn_sniper_shot(direction)

		DebugConfig.log_debug("SniperBoss", "狙撃!")

## 三連狙撃
func _attack_triple_snipe() -> void:
	if player and is_instance_valid(player):
		var base_direction = (player.global_position - global_position).normalized()
		for i in range(-1, 2):
			var angle_offset = deg_to_rad(15.0) * i
			var direction = base_direction.rotated(angle_offset)
			_spawn_sniper_shot(direction)

		DebugConfig.log_debug("SniperBoss", "三連狙撃!")

## スナイパーショット発射
func _spawn_sniper_shot(direction: Vector2) -> void:
	var projectile = PoolManager.get_from_pool("projectile")
	if projectile:
		projectile.global_position = global_position
		projectile.damage = damage
		projectile.direction = direction
		projectile.speed = 400.0  # 高速
		projectile.modulate = Color.LIME_GREEN

		# ボス弾は見た目を大きく
		projectile.scale = Vector2(1.2, 1.2)

		AudioManager.play_sfx("shoot", -10.0)
