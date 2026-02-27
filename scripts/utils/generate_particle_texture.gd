extends Node

## パーティクル用テクスチャ生成スクリプト

func _ready() -> void:
	generate_circle_texture()
	print("✅ パーティクルテクスチャ生成完了")
	get_tree().quit()

func generate_circle_texture() -> void:
	var size = 16
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)

	var center = Vector2(size / 2.0, size / 2.0)
	var radius = size / 2.0 - 1.0

	# 各ピクセルを走査して円を描画
	for y in range(size):
		for x in range(size):
			var pos = Vector2(x, y)
			var distance = pos.distance_to(center)

			if distance <= radius:
				# アンチエイリアス処理（端をソフトに）
				var alpha = 1.0
				if distance > radius - 1.0:
					alpha = 1.0 - (distance - (radius - 1.0))

				# 中心から端に向かってグラデーション
				var gradient = 1.0 - (distance / radius) * 0.3

				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha * gradient))

	# PNG形式で保存
	var path = "res://assets/particles/circle.png"
	var error = image.save_png(path)

	if error == OK:
		print("✅ circle.png 生成成功: %s" % path)
	else:
		push_error("❌ circle.png 生成失敗: error=%d" % error)
