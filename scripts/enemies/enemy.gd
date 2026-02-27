class_name Enemy extends CharacterBody2D

## Enemyクラス（基底クラス）
##
## 責務:
## - 敵の基本動作（移動、HP管理、接触ダメージ）
## - AI Controllerによる行動制御
##
## 重要:
## - PoolManagerで管理される（queue_free禁止）
## - 撃破時は経験値オーブをドロップ

signal died(enemy: Enemy)

## エフェクト用プリロード
const EXPLOSION_SCENE = preload("res://scenes/effects/explosion.tscn")

@export var max_hp: int = 30
@export var speed: float = 100.0
@export var contact_damage: int = 10
@export var exp_value: int = 5
@export var ai_controller: AIController = null

var current_hp: int = max_hp
var player: Node = null

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func initialize(pos: Vector2, target_player: Node) -> void:
	global_position = pos
	player = target_player
	current_hp = max_hp

	# グループに追加（ホーミングミサイルの索敵用）
	if not is_in_group("enemies"):
		add_to_group("enemies")

	# デフォルトAI設定（毎回設定）
	if ai_controller == null:
		ai_controller = AIChasePlayer.new()

	# 衝突有効化
	# Layer 2: 敵レイヤー
	set_collision_layer_value(2, true)
	# Mask: Layer 1 (Player, Projectile)
	set_collision_mask_value(1, true)

func _ready() -> void:
	# CharacterBody2Dはbody_enteredシグナルを持たないため、
	# move_and_slide()後の衝突チェックで対応
	pass

func _process(delta: float) -> void:
	if player == null or ai_controller == null:
		return

	# AIによる移動方向計算
	var direction = ai_controller.calculate_direction(self, player, delta)
	velocity = direction * speed
	move_and_slide()

	# 接触ダメージの処理
	_check_player_collision()

func take_damage(amount: int) -> void:
	if amount <= 0:
		push_warning("Enemy.take_damage: amount <= 0")
		return

	# 既に死んでいる場合は処理しない
	if current_hp <= 0:
		return

	current_hp -= amount

	# ヒット音再生
	AudioManager.play_sfx("hit", -15.0)

	# ビジュアルに通知（ダメージ点滅とHP色変化）
	var visual = get_node_or_null("Visual")
	if visual and visual.has_method("flash_damage"):
		visual.flash_damage()
		var hp_ratio = float(current_hp) / float(max_hp)
		visual.update_hp_ratio(hp_ratio)

	# 与ダメージを記録
	if GameManager.game_stats != null:
		GameManager.game_stats.total_damage_dealt += amount

	if current_hp <= 0:
		_die()

func _die() -> void:
	# コンボシステムに通知
	ComboManager.add_combo()

	# 爆発エフェクト生成
	_spawn_explosion_effect()

	# 爆発音再生
	AudioManager.play_sfx("explosion", -8.0)

	# 経験値オーブをドロップ（コンボボーナス適用）
	if exp_value > 0:
		var multiplier = ComboManager.get_exp_multiplier()
		var final_exp = int(exp_value * multiplier)
		PoolManager.spawn_exp_orb(global_position, final_exp)

	# GameStatsに撃破数を記録
	if GameManager.game_stats != null:
		GameManager.game_stats.add_kill()

	died.emit(self)

	# グループから削除
	remove_from_group("enemies")

	# プールに返却
	PoolManager.return_enemy(self)


func _spawn_explosion_effect() -> void:
	var explosion = EXPLOSION_SCENE.instantiate()
	var game_scene = get_parent()
	if game_scene != null:
		game_scene.add_child(explosion)
		explosion.global_position = global_position
		explosion.emitting = true
		explosion.get_node("Timer").start()

func _check_player_collision() -> void:
	# move_and_slide()後の衝突をチェック
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider != null and collider.has_method("take_damage"):
			collider.take_damage(contact_damage)
			# 連続ダメージを防ぐため、1フレームに1回のみ
			return
