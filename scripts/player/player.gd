class_name Player extends CharacterBody2D

## Playerクラス
##
## 責務:
## - 移動入力処理
## - HP管理
##
## 注意: 武器システムは後で追加

## デバッグコンテキスト名
const DEBUG_CONTEXT: String = "Player"

## エフェクト用プリロード
const LEVEL_UP_SCENE = preload("res://scenes/effects/level_up.tscn")

signal hp_changed(new_hp: int, max_hp: int)
signal died()

const BASE_SPEED: float = 200.0

@export var max_hp: int = 100
@export var speed: float = BASE_SPEED
@export var invincible: bool = false  # パフォーマンステスト用

var current_hp: int = max_hp

## パワーアップ効果管理（キー: 効果名, 値: 残り時間）
var active_powerups: Dictionary = {}

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var weapon_manager: Node = $WeaponManager
@onready var exp_attract_area: Area2D = $ExpAttractArea

func _ready() -> void:
	DebugConfig.log_debug(DEBUG_CONTEXT, "_ready() called")
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)

	# 経験値オーブ吸引エリアのシグナル接続
	if exp_attract_area != null:
		DebugConfig.log_debug(DEBUG_CONTEXT, "Connecting ExpAttractArea.area_entered signal")
		exp_attract_area.area_entered.connect(_on_exp_attract_area_entered)
		DebugConfig.log_trace(DEBUG_CONTEXT, "ExpAttractArea collision_mask: %d" % exp_attract_area.collision_mask)
		DebugConfig.log_trace(DEBUG_CONTEXT, "ExpAttractArea monitoring: %s" % exp_attract_area.monitoring)
	else:
		DebugConfig.log_critical(DEBUG_CONTEXT, "ERROR: exp_attract_area is null!")

	# テスト用: 開始時に武器を追加
	if weapon_manager != null:
		var straight_shot = load("res://resources/weapons/straight_shot.tres")
		weapon_manager.add_weapon(straight_shot)

		# ホーミングミサイルもテスト用に追加（コメントアウト：選択肢を増やすため）
		# var homing_missile = load("res://resources/weapons/homing_missile.tres")
		# weapon_manager.add_weapon(homing_missile)

func _process(delta: float) -> void:
	_handle_input(delta)
	_update_powerups(delta)

func _handle_input(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Speed Boostパワーアップ適用
	var effective_speed = speed
	if has_powerup("speed_boost"):
		effective_speed *= 2.0

	# 氷床の影響（移動速度50%減少）
	if get_meta("on_ice", false):
		effective_speed *= 0.5

	velocity = direction * effective_speed
	move_and_slide()

func take_damage(amount: int) -> void:
	if amount <= 0:
		push_warning("take_damage: amount <= 0")
		return

	# パフォーマンステスト中は無敵
	if invincible:
		return

	# Invincibilityパワーアップで無敵
	if has_powerup("invincibility"):
		DebugConfig.log_debug(DEBUG_CONTEXT, "無敵状態でダメージ無効化")
		return

	current_hp = clampi(current_hp - amount, 0, max_hp)
	hp_changed.emit(current_hp, max_hp)

	# 被ダメージを記録
	if GameManager.game_stats != null:
		GameManager.game_stats.total_damage_taken += amount

	if current_hp <= 0:
		_die()

func heal(amount: int) -> void:
	if amount <= 0:
		push_warning("heal: amount <= 0")
		return

	current_hp = clampi(current_hp + amount, 0, max_hp)
	hp_changed.emit(current_hp, max_hp)

func _die() -> void:
	died.emit()
	# ゲームオーバー処理はGameManagerに委譲

## 経験値オーブが吸引範囲に入った時
func _on_exp_attract_area_entered(area: Area2D) -> void:
	DebugConfig.log_trace(DEBUG_CONTEXT, "_on_exp_attract_area_entered() - area: %s, is_active: %s" % [area.name if area else "null", area.get("is_active") if area else "N/A"])
	# ExpOrbのみ処理
	if area.has_method("start_attraction"):
		DebugConfig.log_trace(DEBUG_CONTEXT, "Calling start_attraction()")
		area.start_attraction(self)
	else:
		DebugConfig.log_critical(DEBUG_CONTEXT, "ERROR: area doesn't have start_attraction method!")

## 経験値オーブを収集
func collect_exp(amount: int) -> void:
	DebugConfig.log_trace(DEBUG_CONTEXT, "collect_exp() called - amount: %d" % amount)

	if amount <= 0:
		push_warning("collect_exp: amount <= 0")
		return

	# コンボ倍率を適用
	var multiplier = ComboManager.get_exp_multiplier()
	var final_amount = int(amount * multiplier)

	DebugConfig.log_debug(DEBUG_CONTEXT, "経験値獲得: %d (倍率: %.1fx)" % [final_amount, multiplier])

	# LevelSystemに経験値を追加
	var leveled_up = LevelSystem.add_exp(final_amount)

	# 経験値取得音
	AudioManager.play_sfx("pickup", -12.0)

	# レベルアップした場合はGameManagerに通知
	if leveled_up:
		DebugConfig.log_info(DEBUG_CONTEXT, "Level up! Changing state to UPGRADE")
		AudioManager.play_sfx("levelup", -5.0)
		_spawn_level_up_effect()
		GameManager.change_state(GameManager.GameState.UPGRADE)


func _spawn_level_up_effect() -> void:
	var level_up = LEVEL_UP_SCENE.instantiate()
	var game_scene = get_parent()
	if game_scene != null:
		game_scene.add_child(level_up)
		level_up.global_position = global_position
		level_up.emitting = true
		level_up.get_node("Timer").start()

## パワーアップ効果を追加
func add_powerup_effect(powerup_name: String, duration: float) -> void:
	active_powerups[powerup_name] = duration
	DebugConfig.log_info(DEBUG_CONTEXT, "パワーアップ取得: %s (%.1f秒)" % [powerup_name, duration])

## パワーアップ効果を持っているか
func has_powerup(powerup_name: String) -> bool:
	return active_powerups.has(powerup_name)

## パワーアップ効果の時間管理
func _update_powerups(delta: float) -> void:
	# Magnetパワーアップの吸引範囲調整
	if exp_attract_area != null:
		var attract_shape = exp_attract_area.get_node_or_null("CollisionShape2D")
		if attract_shape != null:
			if has_powerup("magnet"):
				attract_shape.scale = Vector2(3.0, 3.0)
			else:
				attract_shape.scale = Vector2(1.0, 1.0)

	for powerup_name in active_powerups.keys():
		active_powerups[powerup_name] -= delta
		if active_powerups[powerup_name] <= 0:
			active_powerups.erase(powerup_name)
			DebugConfig.log_debug(DEBUG_CONTEXT, "パワーアップ終了: %s" % powerup_name)
