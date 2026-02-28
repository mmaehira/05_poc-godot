extends Sprite2D

## プレイヤーの見た目を描画（Sprite2D + region_rect方式）
##
## 責務:
## - スプライトアニメーション管理
## - 移動方向に応じた向きの切り替え
## - 状態に応じたアニメーション切り替え

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

## ゲーム内での表示スケール
@export var sprite_scale: float = 1.5

## アニメーション状態
var current_frame: int = 0
var current_row: int = AnimationRow.DOWN
var animation_timer: float = 0.0
var animation_speed: float = 0.15  # 秒/フレーム
var is_walking: bool = false

## エフェクト状態
var original_modulate: Color
var is_skill_color_active: bool = false
var is_hit_animation_playing: bool = false
var hit_flash_timer: float = 0.0


func _ready() -> void:
	# スプライトシートをロード
	var sprite_texture = load("res://assets/characters/player/pipo-charachip018b.png")

	# ロードに失敗した場合は画像から直接読み込み
	if sprite_texture == null:
		print("[PlayerVisual] Compressed texture not found, loading from raw image...")
		var image = Image.new()
		var error = image.load("/workspaces/05_poc-godot/assets/characters/player/pipo-charachip018b.png")
		if error != OK:
			push_error("[PlayerVisual] Failed to load sprite sheet: pipo-charachip018b.png (error: %d)" % error)
			return
		sprite_texture = ImageTexture.create_from_image(image)

	texture = sprite_texture

	if texture == null:
		push_error("[PlayerVisual] Failed to create texture from sprite sheet")
		return

	# Region設定を有効化
	region_enabled = true
	centered = true

	# スケール設定
	scale = Vector2(sprite_scale, sprite_scale)

	# 初期フレーム設定
	_update_region()

	# オリジナルのモジュレーション色を保存
	original_modulate = modulate

	print("[PlayerVisual] Sprite2D + region_rect initialized")
	print("[PlayerVisual] Sprite sheet size: %s" % texture.get_size())
	print("[PlayerVisual] Frame size: %dx%d" % [FRAME_WIDTH, FRAME_HEIGHT])


func _process(delta: float) -> void:
	# ダメージ点滅処理
	if hit_flash_timer > 0.0:
		hit_flash_timer -= delta
		if hit_flash_timer <= 0.0:
			modulate = original_modulate if not is_skill_color_active else modulate

	# 親（Player）の速度を取得して状態更新
	var player = get_parent()
	if player and player is CharacterBody2D:
		var velocity = player.velocity

		# 移動中かどうか判定
		if velocity.length() > 10.0:
			is_walking = true
			_update_direction(velocity)
			_animate(delta)
		else:
			is_walking = false
			current_frame = 1  # 中央フレームで停止
			_update_region()


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


## スキル使用時に5秒間色を変更
func apply_skill_color(skill_color: Color) -> void:
	if is_skill_color_active:
		return  # 既に色変更中は無視

	is_skill_color_active = true
	modulate = skill_color

	# 5秒後に元に戻す
	await get_tree().create_timer(5.0).timeout
	modulate = original_modulate
	is_skill_color_active = false


## ダメージを受けた時のフラッシュエフェクト
func play_hit_animation() -> void:
	# 赤く点滅
	modulate = Color(1.0, 0.5, 0.5)
	hit_flash_timer = 0.2  # 0.2秒間点滅
