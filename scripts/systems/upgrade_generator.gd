# upgrade_generator.gd
# アップグレード選択肢の生成
class_name UpgradeGenerator extends Node

const Weapon = preload("res://resources/weapon.gd")

## アップグレードタイプの列挙
enum UpgradeType {
	NEW_WEAPON,        # 新規武器追加
	WEAPON_LEVEL_UP,   # 武器レベルアップ
	MAX_HP_UP,         # 最大HP増加
	SPEED_UP,          # 移動速度増加
	ATTRACT_RANGE_UP,  # 経験値吸引範囲拡大
	CRITICAL_RATE_UP,  # クリティカル率増加
	AREA_EXPANSION,    # 範囲拡大
	MULTISHOT          # 弾数増加
}

## レアリティの列挙
enum Rarity {
	NORMAL,    # 通常
	ENHANCED,  # 強化
	RARE       # 希少
}

## アップグレード選択肢のデータ構造
class UpgradeOption:
	var type: UpgradeType
	var rarity: Rarity
	var display_name: String
	var description: String
	var value: float  # 効果量（型による）
	var weapon_data: Weapon = null  # NEW_WEAPONの場合の武器データ

	func _init(p_type: UpgradeType, p_rarity: Rarity) -> void:
		type = p_type
		rarity = p_rarity

## 利用可能な武器リスト（プリロード）
const AVAILABLE_WEAPONS: Array[String] = [
	"res://resources/weapons/macrophage_blade.tres",
	"res://resources/weapons/neutro_charge.tres",
	"res://resources/weapons/killer_t_laser.tres",
	"res://resources/weapons/antibody_splitter.tres",
	"res://resources/weapons/nano_homing_orb.tres",
	"res://resources/weapons/cytokine_ring.tres",
	"res://resources/weapons/phagocyte_burst.tres",
	"res://resources/weapons/inflamma_spike.tres",
]

## レアリティの抽選確率（通常 70%, 強化 25%, 希少 5%）
const RARITY_WEIGHTS: Array[float] = [0.7, 0.25, 0.05]

## プレイヤーへの参照（所持武器チェック用）
var player: Node = null


## 初期化
func initialize(target_player: Node) -> void:
	player = target_player


## 3つのアップグレード選択肢を生成
func generate_options() -> Array[UpgradeOption]:
	var options: Array[UpgradeOption] = []
	var used_types: Array[UpgradeType] = []
	var max_attempts: int = 30

	# 3つの選択肢を生成（重複なし）
	while options.size() < 3 and max_attempts > 0:
		max_attempts -= 1
		var option = _generate_single_option(used_types)
		if option != null:
			options.append(option)
			used_types.append(option.type)

	return options


## 単一の選択肢を生成
func _generate_single_option(exclude_types: Array[UpgradeType]) -> UpgradeOption:
	# アップグレードタイプを抽選
	var available_types = _get_available_types(exclude_types)
	if available_types.is_empty():
		push_error("generate_single_option: 利用可能なアップグレードタイプがありません")
		return null

	var type = available_types[randi() % available_types.size()]

	# レアリティを抽選
	var rarity = _roll_rarity()

	# 選択肢を構築
	var option = UpgradeOption.new(type, rarity)
	_populate_option_data(option)

	return option


## 利用可能なアップグレードタイプを取得
func _get_available_types(exclude_types: Array[UpgradeType]) -> Array[UpgradeType]:
	var available: Array[UpgradeType] = []

	# すべてのタイプをチェック
	for type in UpgradeType.values():
		if exclude_types.has(type):
			continue

		# NEW_WEAPONは条件付き
		if type == UpgradeType.NEW_WEAPON:
			if _can_add_weapon():
				available.append(type)
		# WEAPON_LEVEL_UPは武器所持が条件
		elif type == UpgradeType.WEAPON_LEVEL_UP:
			if _has_any_weapon():
				available.append(type)
		else:
			available.append(type)

	return available


## 新規武器追加が可能か
func _can_add_weapon() -> bool:
	if player == null:
		return false

	var weapon_manager = player.get_node_or_null("WeaponManager")
	if weapon_manager == null:
		return false

	# 武器スロットの空きがあるか
	if weapon_manager.weapons.size() >= weapon_manager.MAX_WEAPONS:
		return false

	# まだ所持していない武器があるか
	for weapon_path in AVAILABLE_WEAPONS:
		var weapon = load(weapon_path) as Weapon
		if not weapon_manager.has_weapon(weapon.weapon_name):
			return true

	return false


## 武器を所持しているか
func _has_any_weapon() -> bool:
	if player == null:
		return false

	var weapon_manager = player.get_node_or_null("WeaponManager")
	if weapon_manager == null:
		return false

	return weapon_manager.weapons.size() > 0


## レアリティを抽選
func _roll_rarity() -> Rarity:
	var rand_value = randf()
	var cumulative = 0.0

	for i in range(RARITY_WEIGHTS.size()):
		cumulative += RARITY_WEIGHTS[i]
		if rand_value < cumulative:
			return i as Rarity

	return Rarity.NORMAL  # フォールバック


## 選択肢のデータを設定
func _populate_option_data(option: UpgradeOption) -> void:
	match option.type:
		UpgradeType.NEW_WEAPON:
			_populate_new_weapon(option)
		UpgradeType.WEAPON_LEVEL_UP:
			_populate_weapon_level_up(option)
		UpgradeType.MAX_HP_UP:
			_populate_max_hp_up(option)
		UpgradeType.SPEED_UP:
			_populate_speed_up(option)
		UpgradeType.ATTRACT_RANGE_UP:
			_populate_attract_range_up(option)
		UpgradeType.CRITICAL_RATE_UP:
			_populate_critical_rate_up(option)
		UpgradeType.AREA_EXPANSION:
			_populate_area_expansion(option)
		UpgradeType.MULTISHOT:
			_populate_multishot(option)


## 新規武器追加の選択肢データ
func _populate_new_weapon(option: UpgradeOption) -> void:
	if player == null:
		return

	var weapon_manager = player.get_node_or_null("WeaponManager")
	if weapon_manager == null:
		return

	# まだ所持していない武器をランダム選択
	var available_weapons: Array[Weapon] = []
	for weapon_path in AVAILABLE_WEAPONS:
		var weapon = load(weapon_path) as Weapon
		if not weapon_manager.has_weapon(weapon.weapon_name):
			available_weapons.append(weapon)

	if available_weapons.is_empty():
		push_error("populate_new_weapon: 利用可能な武器がありません")
		return

	option.weapon_data = available_weapons[randi() % available_weapons.size()]
	option.display_name = option.weapon_data.weapon_name
	option.description = option.weapon_data.description


## 武器レベルアップの選択肢データ
func _populate_weapon_level_up(option: UpgradeOption) -> void:
	option.display_name = "武器強化"

	match option.rarity:
		Rarity.NORMAL:
			option.description = "ランダムな武器をLv+1"
			option.value = 1
		Rarity.ENHANCED:
			option.description = "ランダムな武器をLv+2"
			option.value = 2
		Rarity.RARE:
			option.description = "全武器をLv+1"
			option.value = -1  # -1 = 全武器


## 最大HP増加の選択肢データ
func _populate_max_hp_up(option: UpgradeOption) -> void:
	option.display_name = "最大HP増加"

	match option.rarity:
		Rarity.NORMAL:
			option.description = "+20 HP"
			option.value = 20
		Rarity.ENHANCED:
			option.description = "+40 HP"
			option.value = 40
		Rarity.RARE:
			option.description = "+100 HP"
			option.value = 100


## 移動速度増加の選択肢データ
func _populate_speed_up(option: UpgradeOption) -> void:
	option.display_name = "移動速度増加"

	match option.rarity:
		Rarity.NORMAL:
			option.description = "+10% スピード"
			option.value = 0.1
		Rarity.ENHANCED:
			option.description = "+20% スピード"
			option.value = 0.2
		Rarity.RARE:
			option.description = "+50% スピード"
			option.value = 0.5


## 経験値吸引範囲拡大の選択肢データ
func _populate_attract_range_up(option: UpgradeOption) -> void:
	option.display_name = "経験値吸引範囲拡大"

	match option.rarity:
		Rarity.NORMAL:
			option.description = "+20% 範囲"
			option.value = 0.2
		Rarity.ENHANCED:
			option.description = "+40% 範囲"
			option.value = 0.4
		Rarity.RARE:
			option.description = "+100% 範囲"
			option.value = 1.0


## クリティカル率増加の選択肢データ
func _populate_critical_rate_up(option: UpgradeOption) -> void:
	option.display_name = "クリティカル率増加"

	match option.rarity:
		Rarity.NORMAL:
			option.description = "+5% クリティカル率"
			option.value = 0.05
		Rarity.ENHANCED:
			option.description = "+10% クリティカル率"
			option.value = 0.10
		Rarity.RARE:
			option.description = "+20% クリティカル率"
			option.value = 0.20


## 範囲拡大の選択肢データ
func _populate_area_expansion(option: UpgradeOption) -> void:
	option.display_name = "攻撃範囲拡大"

	match option.rarity:
		Rarity.NORMAL:
			option.description = "+15% 範囲"
			option.value = 0.15
		Rarity.ENHANCED:
			option.description = "+30% 範囲"
			option.value = 0.30
		Rarity.RARE:
			option.description = "+60% 範囲"
			option.value = 0.60


## マルチショットの選択肢データ
func _populate_multishot(option: UpgradeOption) -> void:
	option.display_name = "弾数増加"

	match option.rarity:
		Rarity.NORMAL:
			option.description = "+1 弾数"
			option.value = 1
		Rarity.ENHANCED:
			option.description = "+2 弾数"
			option.value = 2
		Rarity.RARE:
			option.description = "+3 弾数"
			option.value = 3
