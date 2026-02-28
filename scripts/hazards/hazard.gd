extends Area2D

## 環境ハザード
## プレイヤーと敵の両方にダメージや効果を与える

@export var hazard_type: HazardManager.HazardType

var warning_duration: float = 1.0
var active_duration: float = 0.0
var is_active: bool = false

@onready var warning_visual: ColorRect = $WarningVisual
@onready var active_visual: ColorRect = $ActiveVisual
@onready var particles: CPUParticles2D = $Particles

var bodies_in_hazard: Array = []
var damage_accumulator: float = 0.0  # ダメージ累積用

func _ready() -> void:
	_setup_hazard()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Layer 7: Hazardレイヤー（Layer 4は敵弾用）
	set_collision_layer_value(7, true)
	# Mask: Layer 1 (Player), Layer 2 (Enemy)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)

	# 警告フェーズ
	warning_visual.show()
	active_visual.hide()
	await get_tree().create_timer(warning_duration).timeout

	# アクティブフェーズ
	_activate()

## ハザードタイプに応じた設定
func _setup_hazard() -> void:
	match hazard_type:
		HazardManager.HazardType.LAVA_POOL:
			active_duration = 8.0
			warning_visual.color = Color(1.0, 0.3, 0.3, 0.5)
			active_visual.color = Color.ORANGE_RED
			particles.color = Color.ORANGE
		HazardManager.HazardType.POISON_CLOUD:
			active_duration = 12.0
			warning_visual.color = Color(0.3, 1.0, 0.3, 0.5)
			active_visual.color = Color.GREEN_YELLOW
			particles.color = Color.CHARTREUSE
		HazardManager.HazardType.LIGHTNING_STRIKE:
			active_duration = 0.1  # 一瞬
			warning_visual.color = Color(1.0, 1.0, 0.3, 0.5)
			active_visual.color = Color.YELLOW
			particles.color = Color.YELLOW
		HazardManager.HazardType.ICE_PATCH:
			active_duration = 10.0
			warning_visual.color = Color(0.3, 0.8, 1.0, 0.5)
			active_visual.color = Color.LIGHT_CYAN
			particles.color = Color.CYAN

## ハザード発動
func _activate() -> void:
	is_active = true
	warning_visual.hide()
	active_visual.show()
	particles.emitting = true

	DebugConfig.log_debug("Hazard", "ハザード発動: %s" % HazardManager.HazardType.keys()[hazard_type])

	# 雷は即座にダメージ
	if hazard_type == HazardManager.HazardType.LIGHTNING_STRIKE:
		_deal_instant_damage()

	await get_tree().create_timer(active_duration).timeout
	queue_free()

## 雷の即座ダメージ
func _deal_instant_damage() -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(100)
			DebugConfig.log_debug("Hazard", "雷ダメージ: %s" % body.name)

func _on_body_entered(body: Node2D) -> void:
	if is_active and not bodies_in_hazard.has(body):
		bodies_in_hazard.append(body)

func _on_body_exited(body: Node2D) -> void:
	bodies_in_hazard.erase(body)

func _process(delta: float) -> void:
	if not is_active:
		return

	# 継続ダメージ（溶岩と毒）- 累積方式
	if hazard_type == HazardManager.HazardType.LAVA_POOL:
		damage_accumulator += 10.0 * delta  # 毎秒10ダメージ
		if damage_accumulator >= 1.0:
			var damage_to_deal = int(damage_accumulator)
			damage_accumulator -= damage_to_deal
			for body in bodies_in_hazard:
				if body.has_method("take_damage"):
					body.take_damage(damage_to_deal)

	elif hazard_type == HazardManager.HazardType.POISON_CLOUD:
		damage_accumulator += 5.0 * delta  # 毎秒5ダメージ
		if damage_accumulator >= 1.0:
			var damage_to_deal = int(damage_accumulator)
			damage_accumulator -= damage_to_deal
			for body in bodies_in_hazard:
				if body.has_method("take_damage"):
					body.take_damage(damage_to_deal)

	# 氷床は移動速度減少（Playerのメタデータで管理）
	elif hazard_type == HazardManager.HazardType.ICE_PATCH:
		for body in bodies_in_hazard:
			if body.is_in_group("player"):
				body.set_meta("on_ice", true)

	# 氷床から出た場合はメタデータをクリア
	var player = get_tree().get_first_node_in_group("player")
	if player != null and hazard_type == HazardManager.HazardType.ICE_PATCH:
		if not bodies_in_hazard.has(player):
			player.set_meta("on_ice", false)
