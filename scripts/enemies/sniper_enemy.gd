class_name SniperEnemy
extends Enemy

## Sniper（狙撃型）
## 遠距離を維持し、予告線でチャージ→高速弾を発射

const _AIKeepDistance = preload("res://resources/ai_keep_distance.gd")
const _SniperAttack = preload("res://scripts/enemies/attacks/sniper_attack.gd")

var _attack_node = null

func _ready() -> void:
	super._ready()
	_apply_stats()

func initialize(pos: Vector2, target_player: Node) -> void:
	_apply_stats()
	super.initialize(pos, target_player)
	if ai_controller is _AIKeepDistance:
		ai_controller.keep_distance = 300.0
		ai_controller.max_range = 400.0
		ai_controller.reset()

	if _attack_node == null:
		_attack_node = _SniperAttack.new()
		_attack_node.attack_damage = 20
		_attack_node.attack_interval = 3.5
		_attack_node.projectile_speed = 450.0
		_attack_node.attack_range = 400.0
		add_child(_attack_node)
	_attack_node.initialize(self, target_player)

func _apply_stats() -> void:
	max_hp = 20
	speed = 50.0
	contact_damage = 3
	exp_value = 12
	current_hp = max_hp
	if ai_controller == null:
		ai_controller = _AIKeepDistance.new()
