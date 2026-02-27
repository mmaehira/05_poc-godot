extends CharacterBody2D
class_name Boss

## ボス基底クラス
## 大量のHPとフェーズシステムを持つ強敵

signal health_changed(current: int, max: int)
signal died()

@export var max_health: int = 5000
@export var move_speed: float = 50.0
@export var damage: int = 20
@export var exp_value: int = 500

var current_health: int
var current_phase: int = 1  # 1 or 2
var player: Node2D = null

@onready var collision_shape = $CollisionShape2D
@onready var visual = $Visual

func _ready() -> void:
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")

	# グループに追加（武器の索敵対象）
	if not is_in_group("enemies"):
		add_to_group("enemies")

	# 衝突設定
	# Layer 2: 敵レイヤー
	set_collision_layer_value(2, true)
	# Mask: Layer 1 (Player, Projectile)
	set_collision_mask_value(1, true)

## ダメージを受ける
func take_damage(amount: int) -> void:
	if amount <= 0:
		return

	# 既に死んでいる場合は処理しない
	if current_health <= 0:
		return

	current_health -= amount
	health_changed.emit(current_health, max_health)

	# ヒット音
	AudioManager.play_sfx("hit", -12.0)

	# フェーズ移行チェック
	if current_health <= max_health / 2 and current_phase == 1:
		_enter_phase_2()

	if current_health <= 0:
		_die()

## フェーズ2に移行（派生クラスでオーバーライド）
func _enter_phase_2() -> void:
	current_phase = 2
	DebugConfig.log_info("Boss", "%s がフェーズ2に移行!" % name)

## 撃破時の処理
func _die() -> void:
	_spawn_drops()
	died.emit()

	# グループから削除
	remove_from_group("enemies")

	queue_free()

## ドロップアイテム生成
func _spawn_drops() -> void:
	# 大量の経験値オーブをドロップ
	for i in range(20):
		var orb = PoolManager.get_from_pool("exp_orb")
		if orb:
			var offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
			orb.global_position = global_position + offset
			orb.exp_amount = int(exp_value / 20.0)  # 合計exp_value

	DebugConfig.log_info("Boss", "%s が撃破された！経験値%dをドロップ" % [name, exp_value])
