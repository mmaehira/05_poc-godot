extends Sprite2D

## ボスの見た目を描画（Sprite2D + region_rect方式）
##
## 責務:
## - ボススプライトアニメーション管理
## - 移動方向に応じた向きの切り替え
## - HP割合に応じた色変化

## スプライトシート設定
const FRAME_WIDTH: int = 96
const FRAME_HEIGHT: int = 96
const FRAMES_PER_ANIMATION: int = 3

## アニメーション行の定義（Y座標）
## pipo-charachip020は96×96フレーム、各ボスが4行（各方向1行）
## GHOST: 行0-3、DEMON: 行4-7（実際は各ボスが2行ずつ）
enum AnimationRow {
	DOWN = 0,
	LEFT = 1,
	RIGHT = 2,
	UP = 3
}

## ボスタイプ（スプライトシート内の位置）
enum BossType {
	GHOST = 0,      # 1行目・2行目 (Y: 0-96)
	DEMON = 2,      # 3行目・4行目 (Y: 96-192)
	SHADOW = 4,     # 5行目・6行目 (Y: 192-288)
	DRAGON = 6      # 7行目・8行目 (Y: 288-384)
}

## ゲーム内での表示スケール
@export var sprite_scale: float = 2.0

## ボス設定
@export var boss_type: BossType = BossType.DRAGON

## アニメーション状態
var current_frame: int = 0
var current_direction: int = AnimationRow.DOWN
var animation_timer: float = 0.0
var animation_speed: float = 0.2  # ボスは少しゆっくり

## エフェクト状態
var original_modulate: Color
var damage_flash_timer: float = 0.0


func _ready() -> void:
	# スプライトシートをロード
	var sprite_texture = load("res://assets/characters/bosses/pipo-charachip020.png")

	# ロードに失敗した場合は画像から直接読み込み
	if sprite_texture == null:
		print("[BossVisual] Compressed texture not found, loading from raw image...")
		var image = Image.new()
		var error = image.load("/workspaces/05_poc-godot/assets/characters/bosses/pipo-charachip020.png")
		if error != OK:
			push_error("[BossVisual] Failed to load sprite sheet: pipo-charachip020.png (error: %d)" % error)
			return
		sprite_texture = ImageTexture.create_from_image(image)

	texture = sprite_texture

	if texture == null:
		push_error("[BossVisual] Failed to create texture from sprite sheet")
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

	print("[BossVisual] Sprite2D + region_rect initialized")
	print("[BossVisual] Boss type: %d" % boss_type)
	print("[BossVisual] Frame size: %dx%d" % [FRAME_WIDTH, FRAME_HEIGHT])


func _process(delta: float) -> void:
	# ダメージ点滅処理
	if damage_flash_timer > 0.0:
		damage_flash_timer -= delta
		if damage_flash_timer <= 0.0:
			_restore_color_by_hp()

	# 常にアニメーション
	_animate(delta)


## 移動方向から表示する行を決定
func update_direction(velocity: Vector2) -> void:
	if velocity.length() < 1.0:
		return  # 移動していない場合は方向を変えない

	var angle = velocity.angle()

	# 角度から4方向を判定
	var new_direction: int

	if angle >= -PI / 4 and angle < PI / 4:
		new_direction = AnimationRow.RIGHT
	elif angle >= PI / 4 and angle < 3 * PI / 4:
		new_direction = AnimationRow.DOWN
	elif angle >= 3 * PI / 4 or angle < -3 * PI / 4:
		new_direction = AnimationRow.LEFT
	else:
		new_direction = AnimationRow.UP

	# 方向が変わったらフレームをリセット
	if new_direction != current_direction:
		current_direction = new_direction
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
	# boss_typeで開始行を決定し、current_directionで方向を決定
	var y = (boss_type + current_direction) * FRAME_HEIGHT
	region_rect = Rect2(x, y, FRAME_WIDTH, FRAME_HEIGHT)


## HP割合に応じた色変化
func update_hp_color(hp_ratio: float) -> void:
	if damage_flash_timer > 0.0:
		return  # ダメージ点滅中は色変更しない

	_restore_color_by_hp(hp_ratio)


func _restore_color_by_hp(hp_ratio: float = 1.0) -> void:
	# HP 100-70%: 通常色
	# HP 70-30%: 黄色みがかる
	# HP 30-0%: 赤みがかる
	if hp_ratio > 0.7:
		modulate = original_modulate
	elif hp_ratio > 0.3:
		modulate = Color(1.0, 1.0, 0.7)  # 薄い黄色
	else:
		modulate = Color(1.0, 0.7, 0.7)  # 薄い赤


## ダメージを受けた時のフラッシュエフェクト
func flash_damage() -> void:
	modulate = Color(1.5, 1.0, 1.0)  # 明るい赤
	damage_flash_timer = 0.1
