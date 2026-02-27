extends Node

## スキルシステム（Playerの子ノード）
## クールダウン制のアクティブスキルを管理

signal skill_used(skill_name: String)
signal cooldown_started(skill_name: String, duration: float)
signal cooldown_updated(skill_name: String, remaining: float)

enum SkillType {
	DASH,          # ダッシュ（無敵時間0.3秒、150px移動、CD 5秒）
	NOVA_BLAST,    # 範囲攻撃（半径200px、ダメージ100、CD 10秒）
	SHIELD,        # シールド（3秒間無敵、CD 15秒）
	TIME_SLOW      # 時間減速（5秒間敵の速度50%減少、CD 20秒）
}

var selected_skill: SkillType = SkillType.DASH
var cooldown_remaining: float = 0.0
var skill_cooldowns: Dictionary = {
	SkillType.DASH: 5.0,
	SkillType.NOVA_BLAST: 10.0,
	SkillType.SHIELD: 15.0,
	SkillType.TIME_SLOW: 20.0
}

@onready var player: CharacterBody2D = get_parent()

func _ready() -> void:
	if player == null:
		push_error("SkillManager: parent (Player) is null")
		return

	# ランダムでスキルを選択（仮実装）
	selected_skill = SkillType.values().pick_random()
	DebugConfig.log_info("SkillManager", "選択されたスキル: %s" % SkillType.keys()[selected_skill])

func _process(delta: float) -> void:
	if cooldown_remaining > 0:
		cooldown_remaining -= delta
		cooldown_updated.emit(SkillType.keys()[selected_skill], cooldown_remaining)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_skill") and cooldown_remaining <= 0:
		use_skill()

## スキルを使用
func use_skill() -> void:
	print("[SkillManager] スキル使用: %s" % SkillType.keys()[selected_skill])

	match selected_skill:
		SkillType.DASH:
			_skill_dash()
		SkillType.NOVA_BLAST:
			_skill_nova_blast()
		SkillType.SHIELD:
			_skill_shield()
		SkillType.TIME_SLOW:
			_skill_time_slow()

	cooldown_remaining = skill_cooldowns[selected_skill]
	skill_used.emit(SkillType.keys()[selected_skill])
	cooldown_started.emit(SkillType.keys()[selected_skill], cooldown_remaining)
	AudioManager.play_sfx("pickup", -8.0)  # スキル使用音（仮）

## Dash: 高速移動 + 短時間無敵
func _skill_dash() -> void:
	var dash_direction = player.velocity.normalized()
	if dash_direction == Vector2.ZERO:
		# 移動していない場合は右方向
		dash_direction = Vector2.RIGHT

	# 0.3秒間無敵
	player.add_powerup_effect("invincibility", 0.3)

	# Tweenで高速移動
	var dash_distance = 150.0
	var dash_duration = 0.2
	var tween = create_tween()
	tween.tween_property(player, "global_position",
		player.global_position + dash_direction * dash_distance, dash_duration)

	DebugConfig.log_info("SkillManager", "Dash使用!")

## Nova Blast: 範囲攻撃
func _skill_nova_blast() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var hit_count = 0

	for enemy in enemies:
		var distance = player.global_position.distance_to(enemy.global_position)
		if distance <= 200 and enemy.has_method("take_damage"):
			enemy.take_damage(100)
			hit_count += 1

	# 爆発エフェクト
	var explosion_scene = load("res://scenes/effects/explosion.tscn")
	var explosion = explosion_scene.instantiate()
	var game_scene = player.get_parent()
	if game_scene != null:
		game_scene.add_child(explosion)
		explosion.global_position = player.global_position
		explosion.scale = Vector2(3.0, 3.0)  # 大きめ
		explosion.emitting = true
		explosion.get_node("Timer").start()

	AudioManager.play_sfx("explosion", -5.0)
	DebugConfig.log_info("SkillManager", "Nova Blast使用! %d体ヒット" % hit_count)

## Shield: シールド（3秒間無敵）
func _skill_shield() -> void:
	player.add_powerup_effect("invincibility", 3.0)
	DebugConfig.log_info("SkillManager", "Shield使用!")

## Time Slow: 時間減速（敵の速度50%減少）
func _skill_time_slow() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in enemies:
		if enemy.has("speed"):
			var original_speed = enemy.speed
			enemy.speed *= 0.5

			# 5秒後に元に戻す
			_restore_enemy_speed.call_deferred(enemy, original_speed, 5.0)

	DebugConfig.log_info("SkillManager", "Time Slow使用! %d体の敵を減速" % enemies.size())

## 敵の速度を元に戻す（遅延実行）
func _restore_enemy_speed(enemy: Node, original_speed: float, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(enemy) and enemy.has("speed"):
		enemy.speed = original_speed

## スキルを変更
func set_skill(skill_type: SkillType) -> void:
	selected_skill = skill_type
	DebugConfig.log_info("SkillManager", "スキル変更: %s" % SkillType.keys()[skill_type])
