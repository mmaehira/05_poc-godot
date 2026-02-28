# Tasklist: ゲームフロー バグ修正

## タスク一覧

- [x] 1. `GameManager` に `STAGE_CLEAR` 状態と `clear_stage()` メソッドを追加
- [x] 2. `WeaponManager` に `reset()` メソッドを追加
- [x] 3. `Player` に `reset()` メソッドを追加（`_ready` から初期武器追加を分離）
- [x] 4. `project.godot` に `pause` 入力アクション（Escape）を追加
- [x] 5. `PauseMenu` シーン・スクリプトを新規作成
- [x] 6. `GameOverScreen` をクリア/ゲームオーバー両対応に変更
- [x] 7. `game.tscn` インラインスクリプトを修正（リセット・クリア・ポーズ・デバッグフラグ）
- [x] 8. コードレビュー実施 & 指摘事項修正

## レビュー指摘への追加修正

- [x] Escape アンポーズ: PauseMenu (PROCESS_MODE_ALWAYS) に _unhandled_input を追加
- [x] 同時発火ガード: _on_boss_defeated / _on_player_died に `if not is_game_running: return`
- [x] 重複リセット削除: _start_game() から LevelSystem.reset() / PoolManager.clear_all_active() 削除
- [x] ポーズ→タイトル: PLAYING を経由せず直接 TITLE 遷移、PoolManager.clear_all_active() 追加
- [x] HUD stage_cleared 対応: GameManager.stage_cleared シグナルに接続
- [x] Orbital ノードリーク: WeaponInstance._exit_tree() でクリーンアップ
- [x] EnemySpawner リセット: reset_timer() メソッド追加、_start_game() で呼び出し
- [x] ComboManager リセット: reset() メソッド追加、_start_game() で呼び出し
- [x] preload 最適化: Player._add_initial_weapon() で load() → preload() に変更

## 方針変更: ステージクリア条件

- [x] BossManager に reset() メソッド追加、_process に PLAYING チェック追加
- [x] ステージクリア条件をタイマー（60秒）→ ボス撃破に変更
- [x] ボス出現後はタイマー（HUD + game.tscn）を停止
- [x] BossManager.boss_defeated シグナルでステージクリアをトリガー
- [x] _start_game() で BossManager.reset() を呼び出し（リトライ時のボスリセット）

## 追加バグ修正

- [x] Player.reset() で max_hp を BASE_MAX_HP にリセット（アップグレードによる増加が残る問題）
- [x] BossHealthBar に GameManager.game_started シグナル接続（リトライ時にHPバーが残る問題）

## コードレビュー第2回 - 追加修正

- [x] Projectile.initialize() で全プロパティをリセット（speed/lifetime/is_homing/attack_type/pierce_count）
- [x] _on_body_entered の爆発処理後に call_deferred("_return_to_pool") と return を追加
- [x] UpgradeGenerator.generate_options() に max_attempts = 30 による無限ループ防止を追加
- [x] MeleeArea._lifetime を 0.2 → 0.4 に延長、_checked_initial フラグで初期オーバーラップを遅延チェック
- [x] WeaponInstance._update_barrier_dot() に無効な敵エントリのクリーンアップ処理を追加
- [x] projectile_visual.gd の visual_type に set プロパティを追加し、_rebuild_visual() を切り出し

## 動作確認項目（Godotエディタで手動確認）
- [x] 起動時にタイトル画面が表示される
- [x] 「ゲーム開始」を押すまで敵が出現しない
- [x] ボス出現後にタイマーが停止する
- [x] ボスを倒すとステージクリア画面が表示される
- [x] Escapeキーでポーズメニューが開閉できる
- [x] リトライ後、武器がstraight_shotのみ・ボスが消えている
- [x] リトライ後、HPが初期値（100）にリセットされている
- [x] リトライ後、ボスHPバーUIが非表示になっている
- [x] タイトルへ戻った後の再開時も状態がリセットされている
