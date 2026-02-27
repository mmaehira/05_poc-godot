extends Area2D

## パワーアップアイテム
## プレイヤーが拾うと一時的な強化効果を得る

@export var powerup_type: PowerUpManager.PowerUpType
@export var lifetime: float = 10.0

@onready var visual: ColorRect = $Visual
@onready var glow_particles: CPUParticles2D = $GlowParticles

var time_alive: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_setup_visual()

	# Layer 3: Itemレイヤー
	set_collision_layer_value(3, true)
	# Mask: Layer 1 (Player)
	set_collision_mask_value(1, true)

## タイプに応じた色を設定
func _setup_visual() -> void:
	match powerup_type:
		PowerUpManager.PowerUpType.INVINCIBILITY:
			visual.color = Color.YELLOW
		PowerUpManager.PowerUpType.DOUBLE_DAMAGE:
			visual.color = Color.RED
		PowerUpManager.PowerUpType.SPEED_BOOST:
			visual.color = Color.CYAN
		PowerUpManager.PowerUpType.MAGNET:
			visual.color = Color.GREEN
		PowerUpManager.PowerUpType.SCREEN_CLEAR:
			visual.color = Color.GOLD

	glow_particles.color = visual.color

func _process(delta: float) -> void:
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()
		return

	# 消える直前の点滅エフェクト
	if time_alive >= lifetime - 2.0:
		visual.modulate.a = 0.5 + 0.5 * sin(time_alive * 10.0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		PowerUpManager.apply_powerup(powerup_type, body)
		AudioManager.play_sfx("pickup", -10.0)
		queue_free()
