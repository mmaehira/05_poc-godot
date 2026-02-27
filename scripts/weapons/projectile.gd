class_name Projectile extends Area2D

## Projectileクラス
##
## 責務:
## - 弾丸の移動処理
## - 敵との衝突判定
## - ホーミング処理（オプション）

var damage: int = 0
var speed: float = 300.0
var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 5.0
var is_homing: bool = false
var attack_type: int = 0  # 武器タイプを保持
var pierce_count: int = 0  # 貫通回数（0=貫通なし、-1=無限貫通）
var _elapsed_time: float = 0.0
var _hit_enemies: Array = []  # 既にヒットした敵を記録（連続ヒット防止）

func initialize(pos: Vector2, dir: Vector2, dmg: int) -> void:
	global_position = pos
	direction = dir.normalized()
	damage = dmg
	_elapsed_time = 0.0
	_hit_enemies.clear()

	# ビジュアルを設定
	_update_visual()

func _ready() -> void:
	# シグナル接続（重複防止）
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_elapsed_time += delta

	# 生存時間超過でプールに返却
	if _elapsed_time >= lifetime:
		_return_to_pool()
		return

	# ホーミング処理
	if is_homing:
		_update_homing_direction()

	# 移動
	global_position += direction * speed * delta

func _update_homing_direction() -> void:
	var nearest_enemy = _get_nearest_enemy()
	if nearest_enemy != null:
		var to_enemy = (nearest_enemy.global_position - global_position).normalized()
		# 徐々に方向転換（完全な追尾ではなく、緩やかに）
		direction = direction.lerp(to_enemy, 0.05)

func _get_nearest_enemy() -> Node:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var nearest: Node = null
	var min_distance: float = INF

	for enemy in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		var distance = global_position.distance_squared_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = enemy

	return nearest

func _on_area_entered(area: Area2D) -> void:
	# 敵との衝突処理（将来的に実装）
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		# 同じ敵に連続でヒットしないようにチェック
		if _hit_enemies.has(body):
			return

		body.take_damage(damage)
		_hit_enemies.append(body)

		# 貫通処理
		if pierce_count == -1:
			# 無限貫通: 消滅しない
			return
		elif pierce_count > 0:
			# 貫通回数を減らす
			pierce_count -= 1
			return
		else:
			# 貫通なし: 通常通り消滅
			# 物理コールバック中なのでcall_deferred()を使用
			call_deferred("_return_to_pool")

func _return_to_pool() -> void:
	PoolManager.return_projectile(self)


func _update_visual() -> void:
	# Visualノードを取得
	var visual = get_node_or_null("Visual")
	if visual == null or not visual.has_method("get_visual_type_from_weapon"):
		return

	# 武器タイプに応じてビジュアルを設定
	const ProjectileVisual = preload("res://scripts/weapons/projectile_visual.gd")
	visual.visual_type = ProjectileVisual.get_visual_type_from_weapon(attack_type)
