# upgrade_applier.gd
# 選択されたアップグレードを適用する
class_name UpgradeApplier extends Node

const UpgradeGenerator = preload("res://scripts/systems/upgrade_generator.gd")

## プレイヤーへの参照
var player: Node = null


## 初期化
func initialize(target_player: Node) -> void:
	player = target_player


## アップグレードを適用
func apply_upgrade(option: UpgradeGenerator.UpgradeOption) -> void:
	if player == null:
		push_error("apply_upgrade: player is null")
		return

	match option.type:
		UpgradeGenerator.UpgradeType.NEW_WEAPON:
			_apply_new_weapon(option)
		UpgradeGenerator.UpgradeType.WEAPON_LEVEL_UP:
			_apply_weapon_level_up(option)
		UpgradeGenerator.UpgradeType.MAX_HP_UP:
			_apply_max_hp_up(option)
		UpgradeGenerator.UpgradeType.SPEED_UP:
			_apply_speed_up(option)
		UpgradeGenerator.UpgradeType.ATTRACT_RANGE_UP:
			_apply_attract_range_up(option)
		UpgradeGenerator.UpgradeType.CRITICAL_RATE_UP:
			_apply_critical_rate_up(option)
		UpgradeGenerator.UpgradeType.AREA_EXPANSION:
			_apply_area_expansion(option)
		UpgradeGenerator.UpgradeType.MULTISHOT:
			_apply_multishot(option)


## 新規武器追加を適用
func _apply_new_weapon(option: UpgradeGenerator.UpgradeOption) -> void:
	if option.weapon_data == null:
		push_error("apply_new_weapon: weapon_data is null")
		return

	var weapon_manager = player.get_node_or_null("WeaponManager")
	if weapon_manager == null:
		push_error("apply_new_weapon: WeaponManager not found")
		return

	var success = weapon_manager.add_weapon(option.weapon_data)
	if success:
		print("新規武器追加: %s" % option.weapon_data.weapon_name)
	else:
		push_warning("apply_new_weapon: 武器追加に失敗")


## 武器レベルアップを適用
func _apply_weapon_level_up(option: UpgradeGenerator.UpgradeOption) -> void:
	var weapon_manager = player.get_node_or_null("WeaponManager")
	if weapon_manager == null:
		push_error("apply_weapon_level_up: WeaponManager not found")
		return

	if weapon_manager.weapons.is_empty():
		push_warning("apply_weapon_level_up: 所持武器なし")
		return

	# value == -1: 全武器をレベルアップ
	if option.value < 0:
		for weapon_instance in weapon_manager.weapons:
			var success = weapon_manager.level_up_weapon(weapon_instance.weapon_data.weapon_name)
			if success:
				print("武器レベルアップ: %s -> Lv%d" % [weapon_instance.weapon_data.weapon_name, weapon_instance.current_level])
	# value >= 1: ランダムな武器を指定レベル分強化
	else:
		var level_ups = int(option.value)
		var random_weapon = weapon_manager.weapons[randi() % weapon_manager.weapons.size()]

		for i in range(level_ups):
			var success = weapon_manager.level_up_weapon(random_weapon.weapon_data.weapon_name)
			if success:
				print("武器レベルアップ: %s -> Lv%d" % [random_weapon.weapon_data.weapon_name, random_weapon.current_level])
			else:
				break  # レベル上限に達した


## 最大HP増加を適用
func _apply_max_hp_up(option: UpgradeGenerator.UpgradeOption) -> void:
	var amount = int(option.value)
	player.max_hp += amount
	player.current_hp += amount  # 現在HPも増加（全回復）
	player.hp_changed.emit(player.current_hp, player.max_hp)
	print("最大HP増加: +%d (合計: %d)" % [amount, player.max_hp])


## 移動速度増加を適用
func _apply_speed_up(option: UpgradeGenerator.UpgradeOption) -> void:
	var multiplier = option.value
	var old_speed = player.speed
	player.speed *= (1.0 + multiplier)
	print("移動速度増加: %.0f -> %.0f (+%.0f%%)" % [old_speed, player.speed, multiplier * 100])


## 経験値吸引範囲拡大を適用
func _apply_attract_range_up(option: UpgradeGenerator.UpgradeOption) -> void:
	var exp_attract_area = player.get_node_or_null("ExpAttractArea")
	if exp_attract_area == null:
		push_error("apply_attract_range_up: ExpAttractArea not found")
		return

	var collision_shape = exp_attract_area.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		push_error("apply_attract_range_up: CollisionShape2D not found")
		return

	var shape = collision_shape.shape as CircleShape2D
	if shape == null:
		push_error("apply_attract_range_up: shape is not CircleShape2D")
		return

	var multiplier = option.value
	var old_radius = shape.radius
	shape.radius *= (1.0 + multiplier)
	print("経験値吸引範囲拡大: %.0f -> %.0f (+%.0f%%)" % [old_radius, shape.radius, multiplier * 100])


## クリティカル率増加を適用
func _apply_critical_rate_up(option: UpgradeGenerator.UpgradeOption) -> void:
	var weapon_manager = player.get_node_or_null("WeaponManager")
	if weapon_manager == null:
		push_error("apply_critical_rate_up: WeaponManager not found")
		return

	var increase = option.value
	if not ("critical_rate" in weapon_manager):
		weapon_manager.set("critical_rate", 0.0)

	var old_rate = weapon_manager.get("critical_rate")
	weapon_manager.set("critical_rate", old_rate + increase)
	print("クリティカル率増加: %.1f%% -> %.1f%% (+%.1f%%)" % [old_rate * 100, weapon_manager.get("critical_rate") * 100, increase * 100])


## 範囲拡大を適用
func _apply_area_expansion(option: UpgradeGenerator.UpgradeOption) -> void:
	var weapon_manager = player.get_node_or_null("WeaponManager")
	if weapon_manager == null:
		push_error("apply_area_expansion: WeaponManager not found")
		return

	var multiplier = option.value
	if not ("area_multiplier" in weapon_manager):
		weapon_manager.set("area_multiplier", 1.0)

	var old_multiplier = weapon_manager.get("area_multiplier")
	weapon_manager.set("area_multiplier", old_multiplier * (1.0 + multiplier))
	print("攻撃範囲拡大: %.1f%% -> %.1f%% (+%.1f%%)" % [old_multiplier * 100, weapon_manager.get("area_multiplier") * 100, multiplier * 100])


## マルチショットを適用
func _apply_multishot(option: UpgradeGenerator.UpgradeOption) -> void:
	var weapon_manager = player.get_node_or_null("WeaponManager")
	if weapon_manager == null:
		push_error("apply_multishot: WeaponManager not found")
		return

	var increase = int(option.value)
	if not ("multishot_count" in weapon_manager):
		weapon_manager.set("multishot_count", 0)

	var old_count = weapon_manager.get("multishot_count")
	weapon_manager.set("multishot_count", old_count + increase)
	print("弾数増加: +%d -> +%d (追加弾数)" % [old_count, weapon_manager.get("multishot_count")])
