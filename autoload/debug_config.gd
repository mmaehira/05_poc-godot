## DebugConfig Autoload
##
## 責務:
## - デバッグログレベルの一元管理
## - リリースビルド時の自動ログ無効化
## - ログ出力の統一インターフェース提供
##
## 使用方法:
## - DebugConfig.log_info("メッセージ") - 通常の情報ログ
## - DebugConfig.log_debug("メッセージ") - 詳細デバッグログ
## - DebugConfig.log_trace("メッセージ") - トレースログ（全イベント）
##
## 設定:
## - CURRENT_LEVELを変更してログレベルを調整
## - リリース時はLogLevel.CRITICALまたはNONEに設定
extends Node

## ログレベル定義
enum LogLevel {
	NONE = 0,      ## ログ出力なし（リリースビルド）
	CRITICAL = 1,  ## エラー・警告のみ（本番環境）
	INFO = 2,      ## 重要な情報のみ（開発中・デフォルト）
	DEBUG = 3,     ## 詳細デバッグ情報（デバッグ時）
	TRACE = 4      ## 全イベントトレース（トラブルシューティング時）
}

## 現在のログレベル
## デフォルト: INFO（開発中）
## リリース時: CRITICALまたはNONEに変更すること
const CURRENT_LEVEL: LogLevel = LogLevel.INFO

## デバッグモード判定（INFO以上）
const IS_DEBUG_MODE: bool = CURRENT_LEVEL >= LogLevel.INFO


## エラー・警告のログ出力（常に出力推奨）
func log_critical(context: String, message: String) -> void:
	if CURRENT_LEVEL >= LogLevel.CRITICAL:
		print("[CRITICAL][%s] %s" % [context, message])


## 重要な情報のログ出力（状態変化、イベント発生）
func log_info(context: String, message: String) -> void:
	if CURRENT_LEVEL >= LogLevel.INFO:
		print("[INFO][%s] %s" % [context, message])


## 詳細デバッグのログ出力（内部状態、パラメータ）
func log_debug(context: String, message: String) -> void:
	if CURRENT_LEVEL >= LogLevel.DEBUG:
		print("[DEBUG][%s] %s" % [context, message])


## トレースログ出力（全イベント、詳細な実行フロー）
func log_trace(context: String, message: String) -> void:
	if CURRENT_LEVEL >= LogLevel.TRACE:
		print("[TRACE][%s] %s" % [context, message])


## デバッグモード判定用ヘルパー
func is_debug() -> bool:
	return IS_DEBUG_MODE


func is_level_enabled(level: LogLevel) -> bool:
	return CURRENT_LEVEL >= level
