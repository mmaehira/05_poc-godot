# Design: ゲームフロー バグ修正

## 変更対象ファイル一覧

| ファイル | 変更内容 |
|----------|----------|
| `autoload/game_manager.gd` | GameState に `STAGE_CLEAR` 追加、`clear_stage()` メソッド追加 |
| `scenes/game.tscn`（インラインスクリプト） | ステージクリア判定、ポーズ入力処理、リセット処理強化、デバッグフラグ修正 |
| `scripts/player/weapon_manager.gd` | `reset()` メソッド追加 |
| `scripts/player/player.gd` | `reset()` メソッド追加（HP, powerups, speed） |
| `scripts/ui/game_over_screen.gd` | ステージクリア表示に対応（タイトル文言の切り替え） |
| `scenes/ui/pause_menu.tscn` | **新規作成**: ポーズメニューUI |
| `scripts/ui/pause_menu.gd` | **新規作成**: ポーズメニューロジック |
| `project.godot` | `pause` 入力アクション追加（Escape キー） |

---

## Bug 1: ステージクリア条件

### 設計方針
- `MAX_GAME_TIME` を `60.0` に変更（本番は `180.0`）
- 時間切れ時を「死亡」ではなく「ステージクリア」として処理
- `GameManager` に `STAGE_CLEAR` 状態と `clear_stage()` メソッドを追加
- `GameOverScreen` を再利用し、クリア/ゲームオーバーで表示内容を切り替え

### GameManager 変更

```gdscript
enum GameState {
    TITLE,
    PLAYING,
    PAUSED,
    UPGRADE,
    GAME_OVER,
    STAGE_CLEAR  # 追加
}

signal stage_cleared()  # 追加

func clear_stage() -> void:
    if game_stats:
        game_stats.end_time = Time.get_ticks_msec()
        game_stats.survival_time = (game_stats.end_time - game_stats.start_time) / 1000.0
        if LevelSystem:
            game_stats.final_level = LevelSystem.current_level
    change_state(GameState.STAGE_CLEAR)
    stage_cleared.emit()
```

### game.tscn インラインスクリプト変更

```gdscript
const MAX_GAME_TIME: float = 60.0  # 1分（本番は180.0）

func _on_time_limit_reached() -> void:
    is_game_running = false
    GameManager.clear_stage()
    if game_over_screen != null and GameManager.game_stats != null:
        game_over_screen.show_result(GameManager.game_stats, true)  # true = クリア
```

### GameOverScreen 変更
`show_game_over()` を `show_result(stats, is_clear)` にリネーム。
`is_clear == true` の場合タイトルを `"ステージクリア！"` に変更。

---

## Bug 2: ポーズメニュー

### 設計方針
- `project.godot` に `pause` アクション（Escape キー）を追加
- `game.tscn` の `_unhandled_input()` で Escape を検知し、ポーズ切り替え
- 新規 `PauseMenu` シーン（CanvasLayer + PanelContainer）を作成
- 「続ける」「タイトルに戻る」の2ボタン

### PauseMenu 構造
```
PauseMenu (CanvasLayer, process_mode=ALWAYS)
  └ PanelContainer (centered, 400x250)
    └ VBoxContainer
      ├ Label "ポーズ"
      ├ Button "続ける"
      └ Button "タイトルに戻る"
```

### game.tscn でのポーズ入力処理
```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        if GameManager.current_state == GameManager.GameState.PLAYING:
            _show_pause_menu()
        elif GameManager.current_state == GameManager.GameState.PAUSED:
            _hide_pause_menu()
```

---

## Bug 3: タイトル画面スキップ修正

### 設計方針
- `SKIP_TITLE_FOR_DEBUG` を `false` に変更
- `DebugConfig` にフラグを移動する案もあるが、今回はシンプルに `false` にするのみ

```gdscript
const SKIP_TITLE_FOR_DEBUG = false
```

---

## Bug 4: ゲーム状態リセット

### 設計方針
- `WeaponManager` に `reset()` メソッドを追加
  - `weapons` 配列内の全ノードを `queue_free()` して配列をクリア
  - `critical_rate = 0.0`, `area_multiplier = 1.0`, `multishot_count = 0` にリセット
- `Player` に `reset()` メソッドを追加
  - `current_hp = max_hp`
  - `active_powerups.clear()`
  - `speed = BASE_SPEED`
  - `weapon_manager.reset()`
  - 初期武器 `straight_shot` を再追加
- `game.tscn` の `_start_game()` から `player.reset()` を呼ぶ

### WeaponManager.reset()

```gdscript
func reset() -> void:
    # 全武器ノードを解放
    for weapon in weapons:
        weapon.queue_free()
    weapons.clear()

    # アップグレード効果をリセット
    critical_rate = 0.0
    area_multiplier = 1.0
    multishot_count = 0
```

### Player.reset()

```gdscript
func reset() -> void:
    current_hp = max_hp
    speed = BASE_SPEED
    active_powerups.clear()
    hp_changed.emit(current_hp, max_hp)

    # 武器リセット & 初期武器追加
    if weapon_manager:
        weapon_manager.reset()
        var straight_shot = load("res://resources/weapons/straight_shot.tres")
        weapon_manager.add_weapon(straight_shot)
```

### game.tscn _start_game() 変更

```gdscript
func _start_game() -> void:
    elapsed_time = 0.0
    is_game_running = true

    if hud != null:
        hud.visible = true

    LevelSystem.reset()
    PoolManager.clear_all_active()

    # プレイヤーをリセット（武器・パワーアップ含む）
    if player != null:
        player.reset()
        player.global_position = Vector2(576, 324)

    GameManager.start_game()
```

---

## 状態遷移図（修正後）

```
TITLE ──[開始ボタン]──→ PLAYING ──[Escape]──→ PAUSED
  ↑                       │  ↑                 │  │
  │                       │  └──[続ける]────────┘  │
  │                       │                        │
  │                       ├──[HP=0]──→ GAME_OVER   │
  │                       │              │         │
  │                       ├──[60秒]──→ STAGE_CLEAR │
  │                       │              │         │
  │                       └──[LvUp]──→ UPGRADE     │
  │                             ↑        │         │
  │                             └────────┘         │
  │                                                │
  └──[タイトルへ]──────────────────────────────────┘
```
