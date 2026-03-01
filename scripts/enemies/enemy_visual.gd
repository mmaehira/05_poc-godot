extends Sprite2D

## 敵の見た目を描画（Sprite2D + region_rect方式）
##
## 責務:
## - スプライトアニメーション管理
## - 移動方向に応じた向きの切り替え
## - HPに応じた色変化
## - ダメージ点滅エフェクト

## スプライトシート設定
const FRAME_WIDTH: int = 32
const FRAME_HEIGHT: int = 32
const FRAMES_PER_ANIMATION: int = 3  # pipo-charachipは3フレーム/行

## アニメーション行の定義（Y座標）
enum AnimationRow {
	DOWN = 0,   # 下向き
	LEFT = 1,   # 左向き
	RIGHT = 2,  # 右向き
	UP = 3      # 上向き
}

## 敵タイプ（どのスプライトシートを使うか）
enum EnemyType {
	BASIC = 0,      # pipo-charachip019.png（青い敵）
	PUMPKIN = 1,    # pipo-halloweenchara2016_02.png（かぼちゃ）
	PURPLE_GHOST = 2, # pipo-halloweenchara2016_23.png（紫ゴースト）
	YELLOW_GHOST = 3, # pipo-halloweenchara2016_13.png（黄色ゴースト）
	RED_SKULL = 4   # pipo-halloweenchara2016_10.png（赤スカル）
}

## ゲーム内での表示スケール
@export var sprite_scale: float = 1.2

## 敵タイプ（エディタで設定可能）
@export var enemy_type: EnemyType = EnemyType.BASIC

## アニメーション状態
var current_frame: int = 0
var current_row: int = AnimationRow.DOWN
var animation_timer: float = 0.0
var animation_speed: float = 0.15  # 秒/フレーム
var is_moving: bool = true

## エフェクト状態
var original_modulate: Color
var damage_flash_timer: float = 0.0


func _ready() -> void:
	# 敵タイプに応じたスプライトシートをロード
	var sprite_path = _get_sprite_path_for_type(enemy_type)
	var sprite_texture = _load_texture(sprite_path)

	if sprite_texture == null:
		push_error("[EnemyVisual] Failed to load sprite sheet for enemy type %d" % enemy_type)
		return

	texture = sprite_texture

	# Region設定を有効化
	region_enabled = true
	centered = true

	# スケール設定
	scale = Vector2(sprite_scale, sprite_scale)

	# 初期フレーム設定
	_update_region()

	# オリジナルのモジュレーション色を保存
	original_modulate = modulate

	DebugConfig.log_info("EnemyVisual", "Sprite2D initialized for enemy type %d" % enemy_type)


func _process(delta: float) -> void:
	# ダメージ点滅処理
	if damage_flash_timer > 0.0:
		damage_flash_timer -= delta
		if damage_flash_timer <= 0.0:
			modulate = original_modulate

	# 親（Enemy）の速度を取得して向きとアニメーション更新
	var enemy = get_parent()
	if enemy and enemy is CharacterBody2D:
		var velocity = enemy.velocity

		# 移動中かどうか判定
		if velocity.length() > 10.0:
			is_moving = true
			_update_direction(velocity)
			_animate(delta)
		else:
			is_moving = false
			current_frame = 1  # 中央フレームで停止
			_update_region()


## 敵タイプに応じたスプライトシートのパスを取得
func _get_sprite_path_for_type(type: EnemyType) -> String:
	match type:
		EnemyType.BASIC:
			return "res://assets/characters/enemies/pipo-charachip019.png"
		EnemyType.PUMPKIN:
			return "res://assets/characters/enemies/pipo-halloweenchara2016_02.png"
		EnemyType.PURPLE_GHOST:
			return "res://assets/characters/enemies/pipo-halloweenchara2016_23.png"
		EnemyType.YELLOW_GHOST:
			return "res://assets/characters/enemies/pipo-halloweenchara2016_13.png"
		EnemyType.RED_SKULL:
			return "res://assets/characters/enemies/pipo-halloweenchara2016_10.png"
		_:
			return "res://assets/characters/enemies/pipo-charachip019.png"


## テクスチャをロード（Godotのリソースシステムを使用）
func _load_texture(resource_path: String) -> Texture2D:
	# Godotのリソースシステムを使用して画像をロード
	DebugConfig.log_info("EnemyVisual", "Attempting to load: %s" % resource_path)
	var texture_resource = load(resource_path)

	if texture_resource == null:
		push_error("[EnemyVisual] Failed to load texture: %s" % resource_path)
		return null

	# Texture2Dとして使用可能か確認
	if not texture_resource is Texture2D:
		push_error("[EnemyVisual] Resource is not a Texture2D: %s" % resource_path)
		return null

	DebugConfig.log_info("EnemyVisual", "Successfully loaded: %s" % resource_path)
	return texture_resource


## 移動方向から表示する行を決定
func _update_direction(velocity: Vector2) -> void:
	var angle = velocity.angle()

	# 角度から4方向を判定
	# angle は -PI ~ PI の範囲
	# 右: -PI/4 ~ PI/4
	# 下: PI/4 ~ 3PI/4
	# 左: 3PI/4 ~ PI または -PI ~ -3PI/4
	# 上: -3PI/4 ~ -PI/4

	var new_row: int

	if angle >= -PI / 4 and angle < PI / 4:
		new_row = AnimationRow.RIGHT
	elif angle >= PI / 4 and angle < 3 * PI / 4:
		new_row = AnimationRow.DOWN
	elif angle >= 3 * PI / 4 or angle < -3 * PI / 4:
		new_row = AnimationRow.LEFT
	else:  # -3PI/4 ~ -PI/4
		new_row = AnimationRow.UP

	# 方向が変わったらフレームをリセット
	if new_row != current_row:
		current_row = new_row
		current_frame = 0
		animation_timer = 0.0


## アニメーション更新
func _animate(delta: float) -> void:
	animation_timer += delta

	if animation_timer >= animation_speed:
		animation_timer = 0.0
		current_frame = (current_frame + 1) % FRAMES_PER_ANIMATION
		_update_region()


## region_rectを更新
func _update_region() -> void:
	var x = current_frame * FRAME_WIDTH
	var y = current_row * FRAME_HEIGHT
	region_rect = Rect2(x, y, FRAME_WIDTH, FRAME_HEIGHT)


## HPに応じた色変化
func update_hp_ratio(hp_ratio: float) -> void:
	if damage_flash_timer > 0.0:
		return  # ダメージ点滅中は色変更しない

	# HP 100-70%: 通常色
	# HP 70-30%: 黄色味
	# HP 30-0%: 赤味
	if hp_ratio > 0.7:
		modulate = Color.WHITE
	elif hp_ratio > 0.3:
		modulate = Color(1.0, 1.0, 0.6)  # 黄色味
	else:
		modulate = Color(1.0, 0.6, 0.6)  # 赤味

	original_modulate = modulate


## プール再利用時にビジュアル状態をリセット
func reset_visual() -> void:
	modulate = Color.WHITE
	original_modulate = Color.WHITE
	damage_flash_timer = 0.0
	current_frame = 0
	current_row = AnimationRow.DOWN
	animation_timer = 0.0
	is_moving = true
	_update_region()


## ダメージを受けた時の点滅エフェクト
func flash_damage() -> void:
	# 白く点滅
	modulate = Color.WHITE
	damage_flash_timer = 0.15  # 0.15秒間点滅
