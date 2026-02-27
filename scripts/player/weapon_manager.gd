class_name WeaponManager extends Node

## WeaponManagerクラス
##
## 責務:
## - 武器インスタンス管理（最大6個）
## - 武器追加・レベルアップ処理

const MAX_WEAPONS: int = 6

var weapons: Array[Node] = []  # Array[WeaponInstance]
var player: Node = null

## アップグレード効果
var critical_rate: float = 0.0       # クリティカル率（0.0-1.0）
var area_multiplier: float = 1.0     # 範囲倍率（1.0 = 100%）
var multishot_count: int = 0         # 追加弾数

## ダメージ倍率を取得（Double Damageパワーアップ対応）
func get_damage_multiplier() -> float:
	var multiplier = 1.0
	if player != null and player.has_powerup("double_damage"):
		multiplier = 2.0
	return multiplier

func _ready() -> void:
	player = get_parent()
	if player == null:
		push_error("WeaponManager: parent (Player) is null")

func add_weapon(weapon_data: Weapon) -> bool:
	if weapon_data == null:
		push_error("add_weapon: weapon_data is null")
		return false

	if weapons.size() >= MAX_WEAPONS:
		push_warning("add_weapon: 武器スロット上限 current=%d max=%d" % [weapons.size(), MAX_WEAPONS])
		return false

	# 同名武器の重複チェック
	if has_weapon(weapon_data.weapon_name):
		push_warning("add_weapon: 武器 '%s' は既に所持しています" % weapon_data.weapon_name)
		return false

	# WeaponInstanceを作成
	var weapon_instance = preload("res://scripts/weapons/weapon_instance.gd").new()
	weapon_instance.name = "WeaponInstance_" + weapon_data.weapon_name
	add_child(weapon_instance)
	weapon_instance.initialize(weapon_data, 1, player)

	weapons.append(weapon_instance)
	print("武器追加: %s (合計: %d個)" % [weapon_data.weapon_name, weapons.size()])
	return true

func level_up_weapon(weapon_name: String) -> bool:
	var weapon = _find_weapon(weapon_name)
	if weapon == null:
		push_warning("level_up_weapon: 武器 '%s' が見つかりません" % weapon_name)
		return false

	weapon.level_up()
	return true

func has_weapon(weapon_name: String) -> bool:
	return _find_weapon(weapon_name) != null

func get_weapon_level(weapon_name: String) -> int:
	var weapon = _find_weapon(weapon_name)
	if weapon == null:
		return 0
	return weapon.current_level

func _find_weapon(weapon_name: String) -> Node:
	for weapon in weapons:
		if weapon.weapon_data != null and weapon.weapon_data.weapon_name == weapon_name:
			return weapon
	return null
