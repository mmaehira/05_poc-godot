extends Node2D

## 弾丸の見た目を描画
##
## 責務:
## - 武器タイプに応じた形状・色
## - グロー（発光）エフェクト
## - 回転アニメーション

enum VisualType {
	STRAIGHT,   # 直線ショット - 青い小円
	HOMING,     # ホーミング - 赤いダイヤモンド
	AREA_BLAST  # 範囲爆発 - オレンジの星
}

@export var visual_type: VisualType = VisualType.STRAIGHT

var rotation_speed: float = 5.0

func _ready() -> void:
	match visual_type:
		VisualType.STRAIGHT:
			_create_straight_visual()
		VisualType.HOMING:
			_create_homing_visual()
		VisualType.AREA_BLAST:
			_create_area_blast_visual()


func _create_straight_visual() -> void:
	# 青い小さな円
	var polygon = Polygon2D.new()
	var radius = 4.0
	var points = PackedVector2Array()
	for i in range(12):
		var angle = i * TAU / 12
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	polygon.polygon = points
	polygon.color = Color(0.3, 0.6, 1.0)  # 青
	add_child(polygon)

	# グロー
	var glow = Polygon2D.new()
	glow.polygon = points
	glow.color = Color(0.6, 0.8, 1.0, 0.3)
	glow.scale = Vector2(1.5, 1.5)
	add_child(glow)


func _create_homing_visual() -> void:
	# 赤いダイヤモンド形
	var polygon = Polygon2D.new()
	var size = 6.0
	polygon.polygon = PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0)
	])
	polygon.color = Color(1.0, 0.3, 0.3)  # 赤
	add_child(polygon)

	# 輪郭線
	var outline = Line2D.new()
	outline.width = 1.5
	outline.default_color = Color(1.0, 0.5, 0.5)
	outline.points = PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0),
		Vector2(0, -size)
	])
	add_child(outline)


func _create_area_blast_visual() -> void:
	# オレンジの星形
	var polygon = Polygon2D.new()
	var outer_radius = 6.0
	var inner_radius = 3.0
	var points = PackedVector2Array()

	for i in range(5):
		var angle_outer = i * TAU / 5 - PI / 2
		var angle_inner = angle_outer + TAU / 10
		points.append(Vector2(cos(angle_outer), sin(angle_outer)) * outer_radius)
		points.append(Vector2(cos(angle_inner), sin(angle_inner)) * inner_radius)

	polygon.polygon = points
	polygon.color = Color(1.0, 0.6, 0.0)  # オレンジ
	add_child(polygon)

	# グロー
	var glow = Polygon2D.new()
	glow.polygon = points
	glow.color = Color(1.0, 0.8, 0.2, 0.4)
	glow.scale = Vector2(1.3, 1.3)
	add_child(glow)


func _process(delta: float) -> void:
	# 星形とダイヤモンドは回転
	if visual_type == VisualType.AREA_BLAST or visual_type == VisualType.HOMING:
		rotation += rotation_speed * delta


## 武器タイプから対応するVisualTypeを取得
static func get_visual_type_from_weapon(attack_type: int) -> VisualType:
	match attack_type:
		0:  # STRAIGHT
			return VisualType.STRAIGHT
		1:  # AREA_BLAST
			return VisualType.AREA_BLAST
		2:  # HOMING
			return VisualType.HOMING
		_:
			return VisualType.STRAIGHT
