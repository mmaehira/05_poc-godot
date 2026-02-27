## LevelSystem Autoload
##
## 責務:
## - 経験値の唯一の管理者（Playerには経験値を持たせない）
## - レベルアップ計算とシグナル発火
## - 経験値成長率による動的レベル計算
##
## 重要:
## - 純粋Autoloadとして使用（シーンに配置しない）
## - 経験値追加時に自動的にレベルアップ判定を実行
## - reset()はGameManager.start_game()から呼ばれる
extends Node

## レベルアップ時に発火（新しいレベルを通知）
signal level_up(new_level: int)
## 経験値変更時に発火（UI更新用）
signal exp_changed(current_exp: int, next_level_exp: int)

## 基礎経験値（レベル1→2に必要な経験値）
const BASE_EXP: int = 10
## 経験値成長率（1レベルごとに必要経験値が増加する倍率）
const EXP_GROWTH_RATE: float = 1.18

## 現在のレベル
var current_level: int = 1
## 現在の経験値（次のレベルまでの累積）
var experience: int = 0
## 次のレベルに必要な経験値
var next_level_exp: int = BASE_EXP


func _ready() -> void:
	# Autoload初期化時は初期値を設定
	current_level = 1
	experience = 0
	next_level_exp = BASE_EXP


## 経験値を追加し、レベルアップ判定を実行する
##
## 経験値オーブから直接呼ばれる。
## レベルアップ条件を満たす場合、自動的にレベルアップを実行。
## 複数回レベルアップする可能性もあるため、while文で判定。
##
## @param amount: 追加する経験値量
## @return: レベルアップした場合true
func add_exp(amount: int) -> bool:
	if amount <= 0:
		push_warning("LevelSystem.add_exp: 経験値量が0以下です amount=%d" % amount)
		return false

	experience += amount
	exp_changed.emit(experience, next_level_exp)

	# レベルアップ判定（複数回レベルアップする可能性もある）
	var leveled_up: bool = false
	while experience >= next_level_exp:
		experience -= next_level_exp
		_level_up()
		leveled_up = true

	# レベルアップ後も経験値変更シグナルを発火（UIの更新用）
	if leveled_up:
		exp_changed.emit(experience, next_level_exp)

	return leveled_up


## ゲーム開始時にレベルシステムをリセットする
##
## GameManager.start_game()から呼ばれる。
func reset() -> void:
	current_level = 1
	experience = 0
	next_level_exp = BASE_EXP
	exp_changed.emit(experience, next_level_exp)


## レベルアップ処理（内部メソッド）
##
## レベルを1増加し、次のレベルに必要な経験値を再計算。
## level_upシグナルを発火してUI/UpgradePanelに通知。
func _level_up() -> void:
	current_level += 1
	next_level_exp = _calculate_next_level_exp(current_level)
	level_up.emit(current_level)


## 次のレベルに必要な経験値を計算する
##
## 計算式: BASE_EXP * (EXP_GROWTH_RATE ^ (level - 1))
## 例:
## - Lv1→2: 10 * (1.18 ^ 0) = 10
## - Lv2→3: 10 * (1.18 ^ 1) = 11.8 → 12
## - Lv10→11: 10 * (1.18 ^ 9) = 44.3 → 44
##
## @param level: レベル（次のレベルの値）
## @return: 必要な経験値
func _calculate_next_level_exp(level: int) -> int:
	if level <= 1:
		return BASE_EXP

	var required_exp: float = float(BASE_EXP) * pow(EXP_GROWTH_RATE, level - 1)
	return int(required_exp)


## 現在のレベルと経験値の状態をデバッグ出力（開発用）
func debug_print_status() -> void:
	print("LevelSystem: Lv.%d (EXP: %d/%d)" % [current_level, experience, next_level_exp])
