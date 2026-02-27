## GameStats Resource
##
## ゲーム統計情報を保持するResourceクラス。
## GameManagerが保持し、ゲームオーバー時のスコア表示等に使用される。
##
## 重要:
## - Dictionaryではなく型安全なResourceとして実装
## - GameManager.start_game()で新規作成される
class_name GameStats extends Resource

## ゲーム開始時刻（ミリ秒）
var start_time: int = 0
## ゲーム終了時刻（ミリ秒）
var end_time: int = 0
## 生存時間（秒）
var survival_time: float = 0.0

## 撃破数
var kill_count: int = 0
## 最終レベル
var final_level: int = 1
## 与えた総ダメージ
var total_damage_dealt: float = 0.0
## 受けた総ダメージ
var total_damage_taken: float = 0.0

## 取得した武器ID配列
var acquired_weapons: Array[String] = []
## 武器レベル: {weapon_id: level}
var weapon_levels: Dictionary = {}


## ゲーム統計をリセットする
##
## start_game()時に呼ばれる。
func reset() -> void:
	start_time = Time.get_ticks_msec()
	end_time = 0
	survival_time = 0.0
	kill_count = 0
	final_level = 1
	total_damage_dealt = 0.0
	total_damage_taken = 0.0
	acquired_weapons.clear()
	weapon_levels.clear()


## 撃破数を1増やす
func add_kill() -> void:
	kill_count += 1


## 武器を追加・レベルアップする
##
## @param weapon_id: 武器ID
## @param level: 武器レベル
func add_weapon(weapon_id: String, level: int) -> void:
	if weapon_id not in acquired_weapons:
		acquired_weapons.append(weapon_id)
	weapon_levels[weapon_id] = level


## リザルト画面用のサマリーを生成する
##
## @return: サマリー文字列
func get_summary() -> String:
	return "生存時間: %.1f秒\n撃破数: %d\n最終レベル: %d" % [
		survival_time,
		kill_count,
		final_level
	]


## 経過時間を取得する（ゲーム進行中用）
##
## @return: 経過時間（秒）
func get_elapsed_time() -> float:
	if start_time == 0:
		return 0.0
	return (Time.get_ticks_msec() - start_time) / 1000.0
