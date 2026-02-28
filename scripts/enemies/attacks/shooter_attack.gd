class_name ShooterAttack extends EnemyAttack

## Shooter攻撃（予告→単発弾）

var _charge_timer: float = 0.0
var _is_charging: bool = false
const CHARGE_DURATION: float = 0.3

func initialize(enemy: Node, player: Node) -> void:
	super.initialize(enemy, player)
	_is_charging = false
	_charge_timer = 0.0

func attack() -> void:
	_is_charging = true
	_charge_timer = 0.0

func _process(delta: float) -> void:
	if _is_charging:
		_charge_timer += delta
		if _charge_timer >= CHARGE_DURATION:
			_is_charging = false
			_fire()
		return

	super._process(delta)

func _fire() -> void:
	if _owner_enemy == null or _player == null:
		return
	if not is_instance_valid(_owner_enemy) or not is_instance_valid(_player):
		return

	var dir = get_direction_to_player()
	var proj = PoolManager.spawn_enemy_projectile(_owner_enemy.global_position, dir, attack_damage)
	if proj != null:
		proj.speed = projectile_speed
