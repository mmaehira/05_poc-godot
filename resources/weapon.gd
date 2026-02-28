class_name Weapon extends Resource

## Weaponクラス
##
## 責務:
## - 武器データ定義（ダメージ、攻撃間隔、攻撃種類）

enum AttackType {
	MELEE_CIRCLE,      ## 近接円範囲（マクロファージ・ブレード）
	RUSH_EXPLODE,      ## 突進爆発（ニュートロ・チャージ）
	PENETRATE_LINE,    ## 貫通直線（キラーTレーザー）
	SPLIT_SHOT,        ## 分裂弾（抗体スプリッター）
	HOMING,            ## 追尾（ナノ・ホーミング球）
	BARRIER_DOT,       ## バリア型DoT+スロー（サイトカイン・リング）
	SHOTGUN,           ## 近距離散弾（ファゴサイト・バースト）
	PLACE_DOT,         ## 設置型DoT（インフラマ・スパイク）
}

@export var weapon_name: String = ""
@export var description: String = ""
@export var base_damage: int = 10
@export var attack_interval: float = 1.0
@export var attack_type: AttackType = AttackType.MELEE_CIRCLE
@export var projectile_count: int = 1
@export var projectile_speed: float = 300.0

## 貫通弾用
@export var pierce_count: int = 0

## 近接円範囲用
@export var melee_radius: float = 60.0
@export var multi_hit_count: int = 1
@export var multi_hit_interval: float = 0.3

## 突進爆発用
@export var explosion_radius: float = 60.0
@export var rush_speed: float = 500.0

## 分裂弾用
@export var split_count: int = 2
@export var split_generation: int = 1

## バリア用
@export var barrier_radius: float = 80.0
@export var slow_factor: float = 0.5
@export var dot_interval: float = 0.5

## 散弾用
@export var spread_angle: float = 45.0

## 設置DoT用
@export var place_count: int = 1
@export var place_duration: float = 3.0
@export var place_radius: float = 40.0
