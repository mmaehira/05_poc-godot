extends "res://scripts/bosses/boss.gd"

## スナイパー型ボス
## 中耐久、中速、遠距離狙撃攻撃とレーザー攻撃

var attack_timer: float = 0.0
const ATTACK_INTERVAL: float = 2.5
const KEEP_DISTANCE: float = 400.0  # プレイヤーから離れた位置をキープ

func _ready() -> void:
	super._ready()
	max_health = 3000
	move_speed = 80.0
	damage = 50
	exp_value = 400

	current_health = max_health

func _physics_process(delta: float) -> void:
	# プレイヤーから一定距離を保つ
	if player and is_instance_valid(player):
		var to_player = player.global_position - global_position
		var distance = to_player.length()

		var direction: Vector2
		if distance < KEEP_DISTANCE:
			# 近すぎる場合は後退
			direction = -to_player.normalized()
		elif distance > KEEP_DISTANCE + 100:
			# 遠すぎる場合は接近
			direction = to_player.normalized()
		else:
			# 適切な距離ならサイドステップ
			direction = Vector2(-to_player.y, to_player.x).normalized()
			if randf() > 0.5:
				direction = -direction

		velocity = direction * move_speed
		move_and_slide()

		# ビジュアルの方向を更新
		if visual and visual.has_method("update_direction"):
			visual.update_direction(velocity)

	# 攻撃パターン
	attack_timer -= delta
	if attack_timer <= 0:
		if current_phase == 1:
			_attack_snipe()
		else:
			_attack_laser()
		attack_timer = ATTACK_INTERVAL

## フェーズ2移行時の変化
func _enter_phase_2() -> void:
	super._enter_phase_2()
	move_speed = 100.0  # より機敏に
	DebugConfig.log_info("SniperBoss", "フェーズ2: レーザー攻撃モード!")

## 狙撃攻撃（プレイヤーに正確に狙いを定める）
func _attack_snipe() -> void:
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		_spawn_boss_projectile(direction, 400.0, Color.CYAN)

		DebugConfig.log_debug("SniperBoss", "狙撃攻撃!")

## レーザー攻撃（貫通する高速弾）
func _attack_laser() -> void:
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()

		# 3連続レーザー
		for i in range(3):
			var spread_angle = (i - 1) * 0.1  # 少し拡散
			var rotated_dir = direction.rotated(spread_angle)
			_spawn_boss_projectile(rotated_dir, 600.0, Color.RED)
			await get_tree().create_timer(0.1).timeout

		DebugConfig.log_debug("SniperBoss", "レーザー攻撃!")

## ボス弾を発射
func _spawn_boss_projectile(direction: Vector2, speed: float, color: Color) -> void:
	var projectile = PoolManager.get_from_pool("projectile")
	if projectile:
		projectile.global_position = global_position
		projectile.damage = damage
		projectile.direction = direction
		projectile.speed = speed
		projectile.modulate = color

		# スナイパー弾は細長く
		projectile.scale = Vector2(0.8, 2.0)

		AudioManager.play_sfx("shoot", -10.0)
