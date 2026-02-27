extends Node2D

## 敵の見た目を描画
##
## 責務:
## - 円形ボディに目のような模様
## - HPに応じた色変化（緑→黄→赤）
## - ダメージを受けた時の点滅エフェクト

@export var enemy_radius: float = 12.0

var body_polygon: Polygon2D
var eye_left: Polygon2D
var eye_right: Polygon2D
var damage_flash_timer: float = 0.0

func _ready() -> void:
	_create_body()
	_create_eyes()


func _create_body() -> void:
	# 円形のボディ
	body_polygon = Polygon2D.new()
	var points = PackedVector2Array()
	for i in range(16):
		var angle = i * TAU / 16
		points.append(Vector2(cos(angle), sin(angle)) * enemy_radius)
	body_polygon.polygon = points
	body_polygon.color = Color(1.0, 0.4, 0.4)  # 初期色（赤）
	add_child(body_polygon)

	# 輪郭線
	var outline = Line2D.new()
	outline.width = 1.5
	outline.default_color = Color(0.8, 0.2, 0.2)
	outline.closed = true
	outline.points = points
	add_child(outline)


func _create_eyes() -> void:
	# 左目
	eye_left = Polygon2D.new()
	var eye_points = PackedVector2Array()
	for i in range(8):
		var angle = i * TAU / 8
		eye_points.append(Vector2(cos(angle), sin(angle)) * 2.5)
	eye_left.polygon = eye_points
	eye_left.color = Color.BLACK
	eye_left.position = Vector2(-enemy_radius * 0.4, -enemy_radius * 0.3)
	add_child(eye_left)

	# 右目
	eye_right = Polygon2D.new()
	eye_right.polygon = eye_points
	eye_right.color = Color.BLACK
	eye_right.position = Vector2(enemy_radius * 0.4, -enemy_radius * 0.3)
	add_child(eye_right)


func _process(delta: float) -> void:
	# ダメージ点滅の処理
	if damage_flash_timer > 0.0:
		damage_flash_timer -= delta
		# 白く点滅
		if body_polygon:
			body_polygon.modulate = Color.WHITE
	else:
		# HPに応じた色に戻す
		_update_color_by_hp()


func update_hp_ratio(hp_ratio: float) -> void:
	# HP割合に応じて色を変更
	_update_color_by_hp_ratio(hp_ratio)


func _update_color_by_hp() -> void:
	# 親（Enemy）からHP情報を取得
	var enemy = get_parent()
	if enemy and enemy.has_method("get") and enemy.get("max_hp") != null:
		var max_hp = enemy.get("max_hp")
		var current_hp = enemy.get("current_hp")
		if max_hp > 0:
			var hp_ratio = float(current_hp) / float(max_hp)
			_update_color_by_hp_ratio(hp_ratio)


func _update_color_by_hp_ratio(hp_ratio: float) -> void:
	if body_polygon == null:
		return

	# HP 100-70%: 緑
	# HP 70-30%: 黄色
	# HP 30-0%: 赤
	if hp_ratio > 0.7:
		body_polygon.color = Color(0.4, 1.0, 0.4)  # 緑
		body_polygon.modulate = Color.WHITE
	elif hp_ratio > 0.3:
		body_polygon.color = Color(1.0, 1.0, 0.4)  # 黄色
		body_polygon.modulate = Color.WHITE
	else:
		body_polygon.color = Color(1.0, 0.4, 0.4)  # 赤
		body_polygon.modulate = Color.WHITE


func flash_damage() -> void:
	# ダメージを受けた時の点滅
	damage_flash_timer = 0.1
