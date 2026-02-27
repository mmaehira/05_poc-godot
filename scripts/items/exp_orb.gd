# exp_orb.gd
# 経験値オーブ: プレイヤーを追尾し、接触で経験値を付与する
class_name ExpOrb extends Area2D

## デバッグコンテキスト名
const DEBUG_CONTEXT: String = "ExpOrb"

## 経験値量
var exp_value: int = 1

## 移動速度（初期は0、プレイヤーの吸引範囲に入ると加速）
var move_speed: float = 0.0

## 最大移動速度
const MAX_SPEED: float = 400.0

## 加速度
const ACCELERATION: float = 1200.0

## 追跡対象のプレイヤー
var target_player: Node = null

## プール管理用のフラグ
var is_active: bool = false

## 生存時間（未収集の場合の自動消滅）
var lifetime: float = 30.0
var _elapsed_time: float = 0.0

@onready var sprite: ColorRect = $ColorRect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	DebugConfig.log_debug(DEBUG_CONTEXT, "_ready() called - name: %s" % name)

	# Area2Dのシグナル接続
	if body_entered.is_connected(_on_body_entered):
		DebugConfig.log_trace(DEBUG_CONTEXT, "body_entered already connected!")
	else:
		body_entered.connect(_on_body_entered)
		DebugConfig.log_debug(DEBUG_CONTEXT, "body_entered connected")

	# レイヤー設定（Layer 3: アイテム）
	collision_layer = 4  # 2^2 = 4 (Layer 3)
	collision_mask = 1   # Layer 1 (Player)

	DebugConfig.log_trace(DEBUG_CONTEXT, "collision_layer=%d, collision_mask=%d" % [collision_layer, collision_mask])

	# 初期状態は非表示・無効化
	visible = false
	set_process(false)

	# コリジョンはシーンファイルで既にfalse/disabledに設定済み


## プールから取得時の初期化
## 注意: PoolManagerからcall_deferredで呼ばれます
func initialize(pos: Vector2, value: int) -> void:
	DebugConfig.log_debug(DEBUG_CONTEXT, "initialize() called (deferred) - pos: %v, value: %d" % [pos, value])

	global_position = pos
	exp_value = value
	move_speed = 0.0
	target_player = null
	is_active = true
	_elapsed_time = 0.0

	visible = true
	set_process(true)
	process_mode = Node.PROCESS_MODE_PAUSABLE

	# コリジョン設定を確実に有効化（物理フレーム中の可能性があるためdeferred使用）
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

	DebugConfig.log_trace(DEBUG_CONTEXT, "After deferred set - process=%s" % is_processing())

	# CollisionShape2Dを有効化（deferredで実行）
	if collision_shape != null:
		collision_shape.set_deferred("disabled", false)
		DebugConfig.log_trace(DEBUG_CONTEXT, "CollisionShape will be enabled via deferred")
	else:
		DebugConfig.log_critical(DEBUG_CONTEXT, "ERROR: collision_shape is null!")


## プールに返却時のリセット
## 注意: この関数はPoolManagerからcall_deferredで呼ばれます
func reset() -> void:
	is_active = false
	target_player = null
	move_speed = 0.0
	_elapsed_time = 0.0

	set_process(false)

	# コリジョンを無効化（物理フレーム中の可能性があるためdeferred使用）
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# CollisionShape2Dを無効化（deferredで実行）
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)


func _process(delta: float) -> void:
	if not is_active:
		return

	# 生存時間のカウント
	_elapsed_time += delta
	if _elapsed_time >= lifetime:
		_return_to_pool()
		return

	# ターゲットがいる場合は追尾
	if target_player != null:
		_move_towards_player(delta)


## プレイヤーに向かって移動
func _move_towards_player(delta: float) -> void:
	if target_player == null:
		return

	# 距離を計算
	var distance = global_position.distance_to(target_player.global_position)

	# 方向を計算
	var direction = (target_player.global_position - global_position).normalized()

	# 加速
	move_speed = min(move_speed + ACCELERATION * delta, MAX_SPEED)

	# 移動
	global_position += direction * move_speed * delta



## プレイヤーの吸引範囲に入った時
func start_attraction(player: Node) -> void:
	if target_player == null:
		DebugConfig.log_trace(DEBUG_CONTEXT, "start_attraction() called - player: %s" % player.name)
		target_player = player
	else:
		DebugConfig.log_trace(DEBUG_CONTEXT, "start_attraction() called but target_player already set")


## プレイヤーとの接触処理
func _on_body_entered(body: Node2D) -> void:
	DebugConfig.log_trace(DEBUG_CONTEXT, "_on_body_entered() called - body: %s, is_active: %s" % [body.name if body else "null", is_active])

	if not is_active:
		DebugConfig.log_trace(DEBUG_CONTEXT, "Not active - ignoring")
		return

	# プレイヤーとの接触を確認
	if body.has_method("collect_exp"):
		DebugConfig.log_trace(DEBUG_CONTEXT, "Calling collect_exp() - exp_value: %d" % exp_value)
		body.collect_exp(exp_value)
		# 物理コールバック中なのでcall_deferredで返却
		call_deferred("_return_to_pool")
	else:
		DebugConfig.log_critical(DEBUG_CONTEXT, "ERROR: body doesn't have collect_exp method!")


## プールに返却
func _return_to_pool() -> void:
	PoolManager.return_exp_orb(self)
