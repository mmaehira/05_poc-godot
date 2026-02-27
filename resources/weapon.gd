class_name Weapon extends Resource

## Weaponクラス
##
## 責務:
## - 武器データ定義（ダメージ、攻撃間隔、攻撃種類）
##
## 注意:
## - これはResourceクラス（Nodeではない）
## - 実際の攻撃処理はWeaponInstanceが担当

enum AttackType {
	STRAIGHT_SHOT,    ## 直線弾（プレイヤーの移動方向）
	AREA_BLAST,       ## 範囲爆発（周囲全方位）
	HOMING_MISSILE,   ## 誘導ミサイル（最も近い敵を追尾）
	PENETRATING,      ## 貫通弾（レーザービーム）
	ORBITAL,          ## 周囲回転（オービタル）
	CHAIN             ## 連鎖攻撃（ライトニング）
}

@export var weapon_name: String = ""
@export var description: String = ""
@export var base_damage: int = 10
@export var attack_interval: float = 1.0
@export var attack_type: AttackType = AttackType.STRAIGHT_SHOT
@export var projectile_count: int = 1
@export var projectile_speed: float = 300.0

## 貫通弾用プロパティ
@export var pierce_count: int = 0  ## 貫通回数（-1で無限貫通）

## オービタル用プロパティ
@export var orbital_radius: float = 80.0  ## 回転半径
@export var orbital_speed: float = 2.0  ## 回転速度（rad/s）
@export var orbital_count: int = 1  ## 衛星の数

## 連鎖攻撃用プロパティ
@export var chain_range: float = 100.0  ## 連鎖範囲
@export var chain_count: int = 3  ## 最大連鎖数
@export var chain_damage_falloff: float = 0.8  ## ダメージ減衰率
