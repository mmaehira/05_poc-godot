extends Node2D

## 弾丸の見た目を描画（免疫メカニックテーマ）
##
## 責務:
## - 武器タイプに応じた形状・色
## - メカニック・ナノテク風のビジュアル
## - 回転アニメーション

enum VisualType {
	PENETRATE,     ## 貫通ビーム - シアンの細長いビーム
	RUSH,          ## 突進弾 - オレンジの丸弾
	HOMING,        ## 追尾 - シアンのダイヤモンド
	SPLIT,         ## 分裂弾 - 白〜青の小円
	SHOTGUN,       ## 散弾 - オレンジの小粒
}

@export var visual_type: VisualType = VisualType.PENETRATE:
	set(value):
		visual_type = value
		_rebuild_visual()

var rotation_speed: float = 5.0


func _ready() -> void:
	_rebuild_visual()


func _rebuild_visual() -> void:
	if not is_inside_tree():
		return

	# 既存の子ノードをクリア
	for child in get_children():
		child.queue_free()

	match visual_type:
		VisualType.PENETRATE:
			_create_penetrate_visual()
		VisualType.RUSH:
			_create_rush_visual()
		VisualType.HOMING:
			_create_homing_visual()
		VisualType.SPLIT:
			_create_split_visual()
		VisualType.SHOTGUN:
			_create_shotgun_visual()


func _create_penetrate_visual() -> void:
	# シアンの細長いビーム
	var polygon = Polygon2D.new()
	polygon.polygon = PackedVector2Array([
		Vector2(-1.5, -6),
		Vector2(1.5, -6),
		Vector2(1.5, 6),
		Vector2(-1.5, 6)
	])
	polygon.color = Color(0.0, 0.9, 1.0)  # シアン
	add_child(polygon)

	# グロー
	var glow = Polygon2D.new()
	glow.polygon = PackedVector2Array([
		Vector2(-3, -8),
		Vector2(3, -8),
		Vector2(3, 8),
		Vector2(-3, 8)
	])
	glow.color = Color(0.0, 0.9, 1.0, 0.3)
	add_child(glow)


func _create_rush_visual() -> void:
	# オレンジの丸弾
	var polygon = Polygon2D.new()
	var radius = 5.0
	var points = PackedVector2Array()
	for i in range(12):
		var angle = i * TAU / 12
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	polygon.polygon = points
	polygon.color = Color(1.0, 0.43, 0.0)  # オレンジ
	add_child(polygon)

	# 白グロー
	var glow = Polygon2D.new()
	glow.polygon = points
	glow.color = Color(1.0, 0.8, 0.4, 0.3)
	glow.scale = Vector2(1.5, 1.5)
	add_child(glow)


func _create_homing_visual() -> void:
	# シアンのダイヤモンド
	var polygon = Polygon2D.new()
	var size = 6.0
	polygon.polygon = PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0)
	])
	polygon.color = Color(0.0, 0.9, 1.0)  # シアン
	add_child(polygon)

	# 輪郭線
	var outline = Line2D.new()
	outline.width = 1.5
	outline.default_color = Color(0.6, 1.0, 1.0)
	outline.points = PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0),
		Vector2(0, -size)
	])
	add_child(outline)


func _create_split_visual() -> void:
	# 白〜青の小円
	var polygon = Polygon2D.new()
	var radius = 3.0
	var points = PackedVector2Array()
	for i in range(10):
		var angle = i * TAU / 10
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	polygon.polygon = points
	polygon.color = Color(0.27, 0.54, 1.0)  # 青
	add_child(polygon)

	# グロー
	var glow = Polygon2D.new()
	glow.polygon = points
	glow.color = Color(0.6, 0.8, 1.0, 0.4)
	glow.scale = Vector2(1.5, 1.5)
	add_child(glow)


func _create_shotgun_visual() -> void:
	# オレンジの小粒
	var polygon = Polygon2D.new()
	var radius = 2.5
	var points = PackedVector2Array()
	for i in range(8):
		var angle = i * TAU / 8
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	polygon.polygon = points
	polygon.color = Color(1.0, 0.57, 0.0)  # オレンジ
	add_child(polygon)


func _process(delta: float) -> void:
	# ホーミングとラッシュは回転
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
