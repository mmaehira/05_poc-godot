extends Node2D

## 弾丸の見た目を描画（武器アイコンテクスチャベース）
##
## 責務:
## - 武器アイコンをスプライトとして表示
## - 武器タイプに応じたサイズ調整
## - 回転アニメーション

enum VisualType {
	PENETRATE,     ## 貫通ビーム
	RUSH,          ## 突進弾
	HOMING,        ## 追尾
	SPLIT,         ## 分裂弾
	SHOTGUN,       ## 散弾
}

@export var visual_type: VisualType = VisualType.PENETRATE:
	set(value):
		visual_type = value
		_rebuild_visual()

## 武器アイコンテクスチャ（setup()経由で設定すること）
var weapon_texture: Texture2D = null

var rotation_speed: float = 5.0

var _sprite: Sprite2D = null


func _ready() -> void:
	_rebuild_visual()


## テクスチャとビジュアルタイプを一括設定（リビルド1回で済む）
func setup(texture: Texture2D, vtype: VisualType) -> void:
	weapon_texture = texture  # setterなし：リビルドされない
	visual_type = vtype       # setterあり：ここで1回だけリビルド


func _rebuild_visual() -> void:
	if not is_inside_tree():
		return

	# 既存の子ノードをクリア
	for child in get_children():
		child.queue_free()
	_sprite = null

	if weapon_texture != null:
		_create_sprite_visual()
	else:
		_create_fallback_visual()


func _create_sprite_visual() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = weapon_texture

	# 武器タイプに応じたスケール（64pxアイコン想定）
	var target_size: float
	match visual_type:
		VisualType.PENETRATE:
			target_size = 20.0
		VisualType.RUSH:
			target_size = 22.0
		VisualType.HOMING:
			target_size = 18.0
		VisualType.SPLIT:
			target_size = 14.0
		VisualType.SHOTGUN:
			target_size = 12.0

	var tex_size = weapon_texture.get_size()
	var scale_factor = target_size / max(tex_size.x, tex_size.y)
	_sprite.scale = Vector2(scale_factor, scale_factor)

	add_child(_sprite)


## テクスチャ未設定時のフォールバック（プロシージャル描画）
func _create_fallback_visual() -> void:
	match visual_type:
		VisualType.PENETRATE:
			_create_penetrate_fallback()
		VisualType.RUSH:
			_create_rush_fallback()
		VisualType.HOMING:
			_create_homing_fallback()
		VisualType.SPLIT:
			_create_split_fallback()
		VisualType.SHOTGUN:
			_create_shotgun_fallback()


func _create_penetrate_fallback() -> void:
	var polygon = Polygon2D.new()
	polygon.polygon = PackedVector2Array([
		Vector2(-1.5, -6), Vector2(1.5, -6),
		Vector2(1.5, 6), Vector2(-1.5, 6)
	])
	polygon.color = Color(0.0, 0.9, 1.0)
	add_child(polygon)


func _create_rush_fallback() -> void:
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	for i in range(12):
		var angle = i * TAU / 12
		points.append(Vector2(cos(angle), sin(angle)) * 5.0)
	polygon.polygon = points
	polygon.color = Color(1.0, 0.43, 0.0)
	add_child(polygon)


func _create_homing_fallback() -> void:
	var polygon = Polygon2D.new()
	var size = 6.0
	polygon.polygon = PackedVector2Array([
		Vector2(0, -size), Vector2(size, 0),
		Vector2(0, size), Vector2(-size, 0)
	])
	polygon.color = Color(0.0, 0.9, 1.0)
	add_child(polygon)


func _create_split_fallback() -> void:
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	for i in range(10):
		var angle = i * TAU / 10
		points.append(Vector2(cos(angle), sin(angle)) * 3.0)
	polygon.polygon = points
	polygon.color = Color(0.27, 0.54, 1.0)
	add_child(polygon)


func _create_shotgun_fallback() -> void:
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	for i in range(8):
		var angle = i * TAU / 8
		points.append(Vector2(cos(angle), sin(angle)) * 2.5)
	polygon.polygon = points
	polygon.color = Color(1.0, 0.57, 0.0)
	add_child(polygon)


func _process(delta: float) -> void:
	if visual_type == VisualType.HOMING or visual_type == VisualType.RUSH:
		rotation += rotation_speed * delta


## 武器タイプから対応するVisualTypeを取得
static func get_visual_type_from_weapon(attack_type: int) -> VisualType:
	match attack_type:
		2:  # PENETRATE_LINE
			return VisualType.PENETRATE
		1:  # RUSH_EXPLODE
			return VisualType.RUSH
		4:  # HOMING
			return VisualType.HOMING
		3:  # SPLIT_SHOT
			return VisualType.SPLIT
		6:  # SHOTGUN
			return VisualType.SHOTGUN
		_:
			return VisualType.PENETRATE
