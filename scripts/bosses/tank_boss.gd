extends "res://scripts/bosses/boss.gd"

## タンク型ボス
## 高耐久、低速、360度攻撃とバラージ攻撃

var attack_timer: float = 0.0
const ATTACK_INTERVAL: float = 3.0

func _ready() -> void:
	super._ready()
	max_health = 5000
	move_speed = 30.0
	damage = 30
	exp_value = 500

	visual.modulate = Color.DARK_RED
	visual.custom_minimum_size = Vector2(60, 60)

	current_health = max_health

func _physics_process(delta: float) -> void:
	# プレイヤーに向かって移動
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()

	# 攻撃パターン
	attack_timer -= delta
	if attack_timer <= 0:
		if current_phase == 1:
			_attack_shockwave()
		else:
			_attack_barrage()
		attack_timer = ATTACK_INTERVAL

## フェーズ2移行時の変化
func _enter_phase_2() -> void:
	super._enter_phase_2()
	move_speed = 20.0  # さらに遅く
	visual.modulate = Color.DARK_VIOLET

## 衝撃波攻撃（360度12方向）
func _attack_shockwave() -> void:
	for i in range(12):
		var angle = (TAU / 12.0) * i
		var direction = Vector2.RIGHT.rotated(angle)
		_spawn_boss_projectile(direction)

	DebugConfig.log_debug("TankBoss", "衝撃波攻撃!")

## バラージ攻撃（プレイヤー方向に3連射）
func _attack_barrage() -> void:
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		for i in range(3):
			await get_tree().create_timer(0.2).timeout
			_spawn_boss_projectile(direction)

		DebugConfig.log_debug("TankBoss", "バラージ攻撃!")

## ボス弾を発射
func _spawn_boss_projectile(direction: Vector2) -> void:
	var projectile = PoolManager.get_from_pool("projectile")
	if projectile:
		projectile.global_position = global_position
		projectile.damage = damage
		projectile.direction = direction
		projectile.speed = 200.0
		projectile.modulate = Color.ORANGE_RED

		# ボス弾は見た目を大きく
		projectile.scale = Vector2(1.5, 1.5)

		AudioManager.play_sfx("shoot", -12.0)
