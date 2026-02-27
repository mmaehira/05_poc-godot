extends Polygon2D

## プレイヤーの見た目を描画
##
## 責務:
## - 三角形の船型デザイン
## - 移動方向への回転
## - グラデーション表現

@export var base_color: Color = Color(0.3, 0.6, 1.0)  # 青色
@export var glow_color: Color = Color(0.6, 0.8, 1.0)  # 明るい青

var target_rotation: float = 0.0

func _ready() -> void:
	# 三角形の頂点を定義（上向き）
	var size = 16.0
	polygon = PackedVector2Array([
		Vector2(0, -size),      # 先端（上）
		Vector2(-size*0.6, size),   # 左下
		Vector2(size*0.6, size)     # 右下
	])

	color = base_color

	# 輪郭線を追加
	var outline = Line2D.new()
	outline.width = 2.0
	outline.default_color = Color.WHITE
	outline.points = PackedVector2Array([
		Vector2(0, -size),
		Vector2(-size*0.6, size),
		Vector2(size*0.6, size),
		Vector2(0, -size)
	])
	add_child(outline)


func _process(delta: float) -> void:
	# 親（Player）の速度を取得して回転
	var player = get_parent()
	if player and player is CharacterBody2D:
		if player.velocity.length() > 10.0:
			target_rotation = player.velocity.angle() + PI / 2
			rotation = lerp_angle(rotation, target_rotation, delta * 10.0)
