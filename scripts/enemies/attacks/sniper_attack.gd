class_name SniperAttack extends EnemyAttack

## Sniper攻撃（予告線→方向ロック→高速弾）

const CHARGE_DURATION: float = 1.0
const LOCK_DURATION: float = 0.2

var _is_charging: bool = false
var _charge_timer: float = 0.0
var _aim_line: Line2D = null
var _locked_direction: Vector2 = Vector2.ZERO

func initialize(enemy: Node, player: Node) -> void:
	super.initialize(enemy, player)
	_remove_aim_line()
	_is_charging = false
	_charge_timer = 0.0
	_locked_direction = Vector2.ZERO

func attack() -> void:
	_is_charging = true
	_charge_timer = 0.0
	_spawn_aim_line()

func _process(delta: float) -> void:
	if _is_charging:
		_charge_timer += delta

		if _charge_timer < CHARGE_DURATION - LOCK_DURATION:
			# エイム追従
			if _aim_line and is_instance_valid(_owner_enemy) and is_instance_valid(_player):
				var dir = get_direction_to_player()
				_aim_line.global_position = _owner_enemy.global_position
				_aim_line.points = PackedVector2Array([Vector2.ZERO, dir * 500.0])
				# 明滅
				var alpha = 0.3 + sin(_charge_timer * 20.0) * 0.2
				_aim_line.default_color = Color(1.0, 0.0, 0.0, alpha)
				_locked_direction = dir
		elif _charge_timer < CHARGE_DURATION:
			# 方向ロック + 太い線
			if _aim_line:
				_aim_line.width = 4.0
				_aim_line.default_color = Color(1.0, 0.0, 0.0, 0.8)
		else:
			# 発射
			_is_charging = false
			_remove_aim_line()
			_fire()
		return

	super._process(delta)

func _spawn_aim_line() -> void:
	_aim_line = Line2D.new()
	_aim_line.width = 2.0
	_aim_line.default_color = Color(1.0, 0.0, 0.0, 0.3)
	var game_scene = _owner_enemy.get_parent()
	if game_scene:
		game_scene.add_child(_aim_line)

func _remove_aim_line() -> void:
	if _aim_line and is_instance_valid(_aim_line):
		_aim_line.queue_free()
		_aim_line = null

func _fire() -> void:
	if _owner_enemy == null or _player == null:
		return
	if not is_instance_valid(_owner_enemy):
		return

	var proj = PoolManager.spawn_enemy_projectile(_owner_enemy.global_position, _locked_direction, attack_damage)
	if proj != null:
		proj.speed = projectile_speed
