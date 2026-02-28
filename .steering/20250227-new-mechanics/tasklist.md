# フェーズC: 新メカニクス導入 - タスクリスト

**作成日**: 2026-02-27
**更新日**: 2026-02-27
**フェーズ**: C (New Mechanics)
**ステータス**: 準備完了（Phase 1開始可能）

---

## プロジェクト概要

5つの新メカニクス（ボス、パワーアップ、スキル、ハザード、コンボ）を既存ゲームに統合します。
全ての核となるスクリプト（Autoload、クラス）は既に実装済みであり、**残作業はシーンファイル作成と既存コードの軽微な修正のみ**です。

**推定総作業時間**: 約6-8時間
**最優先フェーズ**: Phase 1（シーンファイル作成）- これが完了すればゲーム起動可能

---

## 全体進捗サマリー

| Phase | タスク数 | 推定時間 | 依存関係 | 状態 |
|-------|---------|---------|---------|------|
| Phase 1: シーンファイル作成 | 10 | 3-4時間 | なし | 🔴 未着手 |
| Phase 2: project.godot設定 | 2 | 15分 | Phase 1完了 | 🔴 未着手 |
| Phase 3: 既存スクリプト修正 | 4 | 30分 | Phase 2完了 | 🔴 未着手 |
| Phase 4: GameScene統合 | 1 | 30分 | Phase 3完了 | 🔴 未着手 |
| Phase 5: 統合テスト | 5 | 1-2時間 | Phase 4完了 | 🔴 未着手 |
| Phase 6: バランス調整 | 3 | 1時間 | Phase 5完了 | 🔴 未着手 |

**凡例**:
- 🔴 未着手
- 🟡 進行中
- 🟢 完了

---

## Phase 1: シーンファイル作成（優先度: 最高）

**推定時間**: 3-4時間
**依存**: なし
**目的**: 既存スクリプトをアタッチするシーンファイルを作成

### Phase 1-1: Tank Boss シーン作成

- [ ] **タスク**: `scenes/bosses/tank_boss.tscn` を新規作成
- **詳細説明**:
  - Godotエディタで新規シーン作成（CharacterBody2D）
  - スクリプトを `scripts/bosses/tank_boss.gd` にアタッチ
  - 必須ノード構成:
    ```
    TankBoss (CharacterBody2D)
    ├── CollisionShape2D（RectangleShape2D: 60x60）
    └── Visual (ColorRect: 60x60, color: DARK_RED)
    ```
  - エクスポート変数をインスペクタで設定:
    - `max_health`: 5000
    - `move_speed`: 30.0
    - `damage`: 30
    - `exp_value`: 500
  - 衝突レイヤー: Layer 2（敵）
  - 衝突マスク: Layer 1（プレイヤー + 弾丸）
- **検証方法**: シーンを単体でF6実行し、エラーがないこと
- **見積もり時間**: 20分
- **依存タスク**: なし
- **参照ドキュメント**: `design.md` 2.2節（225-324行目）

---

### Phase 1-2: Sniper Boss シーン作成

- [ ] **タスク**: `scenes/bosses/sniper_boss.tscn` を新規作成
- **詳細説明**:
  - Godotエディタで新規シーン作成（CharacterBody2D）
  - スクリプトを `scripts/bosses/sniper_boss.gd` にアタッチ
  - 必須ノード構成:
    ```
    SniperBoss (CharacterBody2D)
    ├── CollisionShape2D（RectangleShape2D: 40x40）
    └── Visual (ColorRect: 40x40, color: DARK_GREEN)
    ```
  - エクスポート変数をインスペクタで設定:
    - `max_health`: 2000
    - `move_speed`: 80.0
    - `damage`: 50
    - `exp_value`: 500
  - 衝突レイヤー: Layer 2（敵）
  - 衝突マスク: Layer 1（プレイヤー + 弾丸）
- **検証方法**: シーンを単体でF6実行し、エラーがないこと
- **見積もり時間**: 20分
- **依存タスク**: なし
- **参照ドキュメント**: `design.md` 2.2節（326-413行目）

---

### Phase 1-3: Swarm Boss シーン作成

- [ ] **タスク**: `scenes/bosses/swarm_boss.tscn` を新規作成
- **詳細説明**:
  - Godotエディタで新規シーン作成（CharacterBody2D）
  - スクリプトを `scripts/bosses/swarm_boss.gd` にアタッチ
  - 必須ノード構成:
    ```
    SwarmBoss (CharacterBody2D)
    ├── CollisionShape2D（RectangleShape2D: 50x50）
    └── Visual (ColorRect: 50x50, color: PURPLE)
    ```
  - エクスポート変数をインスペクタで設定:
    - `max_health`: 3000
    - `move_speed`: 60.0
    - `damage`: 15
    - `exp_value`: 500
  - 衝突レイヤー: Layer 2（敵）
  - 衝突マスク: Layer 1（プレイヤー + 弾丸）
- **検証方法**: シーンを単体でF6実行し、エラーがないこと
- **見積もり時間**: 20分
- **依存タスク**: なし
- **参照ドキュメント**: `design.md` 2.2節（415-481行目）

---

### Phase 1-4: PowerUp シーン作成

- [ ] **タスク**: `scenes/items/powerup.tscn` を新規作成
- **詳細説明**:
  - Godotエディタで新規シーン作成（Area2D）
  - スクリプトを `scripts/items/powerup.gd` にアタッチ
  - 必須ノード構成:
    ```
    PowerUp (Area2D)
    ├── CollisionShape2D（CircleShape2D: radius 20）
    ├── Visual (ColorRect: 30x30, 中心配置)
    └── GlowParticles (CPUParticles2D)
    ```
  - CPUParticles2D設定:
    - Amount: 20
    - Lifetime: 1.0
    - Emission Shape: Sphere (radius 15)
    - Scale: 0.5
    - Color: 黄色（後でスクリプトが上書き）
  - 衝突レイヤー: Layer 3（アイテム）
  - 衝突マスク: Layer 1（プレイヤー）
- **検証方法**: シーンを単体でF6実行し、パーティクルが表示されること
- **見積もり時間**: 25分
- **依存タスク**: なし
- **参照ドキュメント**: `design.md` 3.1節（619-673行目）

---

### Phase 1-5: Hazard シーン作成

- [ ] **タスク**: `scenes/hazards/hazard.tscn` を新規作成
- **詳細説明**:
  - Godotエディタで新規シーン作成（Area2D）
  - スクリプトを `scripts/hazards/hazard.gd` にアタッチ
  - 必須ノード構成:
    ```
    Hazard (Area2D)
    ├── CollisionShape2D（CircleShape2D: radius 80）
    ├── WarningVisual (ColorRect: 160x160, 中心配置, alpha: 0.5)
    ├── ActiveVisual (ColorRect: 160x160, 中心配置)
    └── Particles (CPUParticles2D)
    ```
  - CPUParticles2D設定:
    - Amount: 50
    - Lifetime: 1.5
    - Emission Shape: Sphere (radius 70)
    - Direction: (0, -1) 上向き
    - Spread: 45度
    - Initial Velocity: 30
  - 衝突レイヤー: Layer 4（ハザード）
  - 衝突マスク: Layer 1（プレイヤー）+ Layer 2（敵）
- **検証方法**: シーンを単体でF6実行し、警告表示とパーティクルが表示されること
- **見積もり時間**: 30分
- **依存タスク**: なし
- **参照ドキュメント**: `design.md` 5.1節（1114-1240行目）

---

### Phase 1-6: BossHealthBar UI シーン作成

- [ ] **タスク**: `scenes/ui/boss_health_bar.tscn` を新規作成
- **詳細説明**:
  - Godotエディタで新規シーン作成（Control）
  - スクリプトを `scripts/ui/boss_health_bar.gd` にアタッチ
  - 必須ノード構成:
    ```
    BossHealthBar (Control)
    ├── Panel (Panel: 幅800px, 高さ80px, 画面上部中央)
    ├── BossNameLabel (Label: 左上配置, フォントサイズ24)
    └── HealthBar (ProgressBar: 幅750px, 高さ30px)
    ```
  - ProgressBar設定:
    - Max Value: 5000（後でスクリプトが上書き）
    - Show Percentage: false
    - Fill Mode: Begin to End
  - Control設定:
    - Anchors Preset: Top Wide
    - Margin Top: 10
    - process_mode: PROCESS_MODE_ALWAYS
- **検証方法**: シーンを単体でF6実行し、レイアウトが正しいこと
- **見積もり時間**: 20分
- **依存タスク**: なし
- **参照ドキュメント**: `design.md` 2.4節（571-612行目）

---

### Phase 1-7: PowerupTimerDisplay UI シーン作成

- [ ] **タスク**: `scenes/ui/powerup_timer_display.tscn` を新規作成
- **詳細説明**:
  - Godotエディタで新規シーン作成（Control）
  - スクリプトを `scripts/ui/powerup_timer_display.gd` にアタッチ
  - 必須ノード構成:
    ```
    PowerupTimerDisplay (Control)
    └── VBoxContainer (VBoxContainer: 右上配置, Separation: 5)
    ```
  - Control設定:
    - Anchors Preset: Top Right
    - Margin: (右10, 上10)
    - process_mode: PROCESS_MODE_ALWAYS
- **検証方法**: シーンを単体でF6実行し、エラーがないこと
- **見積もり時間**: 15分
- **依存タスク**: Phase 1-8完了（powerup_icon参照のため）
- **参照ドキュメント**: `design.md` 3.4節（809-861行目）

---

### Phase 1-8: PowerupIcon UI シーン作成

- [ ] **タスク**: `scenes/ui/powerup_icon.tscn` を新規作成
- **詳細説明**:
  - Godotエディタで新規シーン作成（HBoxContainer）
  - スクリプトを `scripts/ui/powerup_icon.gd` にアタッチ（**新規作成必要**）
  - 必須ノード構成:
    ```
    PowerupIcon (HBoxContainer)
    ├── IconLabel (Label: 幅40px, 中央揃え, フォントサイズ20)
    └── TimerLabel (Label: 幅60px, 右揃え, フォントサイズ16)
    ```
  - HBoxContainer設定:
    - Separation: 10
    - Custom Minimum Size: (100, 40)
- **検証方法**: シーンを単体でF6実行し、レイアウトが正しいこと
- **見積もり時間**: 20分
- **依存タスク**: なし（スクリプト `scripts/ui/powerup_icon.gd` はPhase 3で作成）
- **参照ドキュメント**: `design.md` 3.4節（863-897行目）

---

### Phase 1-9: SkillCooldownDisplay UI シーン作成

- [ ] **タスク**: `scenes/ui/skill_cooldown_display.tscn` を新規作成
- **詳細説明**:
  - Godotエディタで新規シーン作成（Control）
  - スクリプトを `scripts/ui/skill_cooldown_display.gd` にアタッチ
  - 必須ノード構成:
    ```
    SkillCooldownDisplay (Control: 100x100)
    ├── SkillIcon (ColorRect: 80x80, 中心配置)
    ├── CooldownOverlay (ColorRect: 80x80, color: BLACK alpha 0.7)
    ├── CooldownLabel (Label: 中央配置, フォントサイズ24)
    └── SkillNameLabel (Label: 下部配置, フォントサイズ12)
    ```
  - Control設定:
    - Anchors Preset: Bottom Center
    - Margin Bottom: 20
    - process_mode: PROCESS_MODE_ALWAYS
- **検証方法**: シーンを単体でF6実行し、レイアウトが正しいこと
- **見積もり時間**: 25分
- **依存タスク**: なし
- **参照ドキュメント**: `design.md` 4.2節（1039-1107行目）

---

### Phase 1-10: ComboDisplay UI シーン作成

- [ ] **タスク**: `scenes/ui/combo_display.tscn` を新規作成
- **詳細説明**:
  - Godotエディタで新規シーン作成（Control）
  - スクリプトを `scripts/ui/combo_display.gd` にアタッチ
  - 必須ノード構成:
    ```
    ComboDisplay (Control)
    ├── Panel (Panel: 300x150, 中心配置)
    ├── ComboLabel (Label: 中央配置, フォントサイズ48, 太字)
    ├── MultiplierLabel (Label: 下部配置, フォントサイズ24)
    └── TimerBar (ProgressBar: 幅280px, 高さ10px, 下部配置)
    ```
  - Control設定:
    - Anchors Preset: Top Center
    - Margin Top: 100
    - process_mode: PROCESS_MODE_ALWAYS
- **検証方法**: シーンを単体でF6実行し、レイアウトが正しいこと
- **見積もり時間**: 25分
- **依存タスク**: なし
- **参照ドキュメント**: `design.md` 6.3節（1303-1360行目）

---

## Phase 2: project.godot設定（優先度: 最高）

**推定時間**: 15分
**依存**: Phase 1完了
**目的**: Autoloadの登録と入力マップ設定

### Phase 2-1: Autoload 4つを登録

- [ ] **タスク**: `project.godot` にAutoloadを追加
- **詳細説明**:
  - Godotエディタ: プロジェクト設定 > Autoload タブ
  - 以下を追加（既存のGameManager、LevelSystem、PoolManagerの後に）:
    ```ini
    [autoload]
    GameManager="*res://autoload/game_manager.gd"
    LevelSystem="*res://autoload/level_system.gd"
    PoolManager="*res://autoload/pool_manager.gd"
    AudioManager="*res://autoload/audio_manager.gd"
    DebugConfig="*res://autoload/debug_config.gd"
    BossManager="*res://autoload/boss_manager.gd"        # 新規追加
    PowerUpManager="*res://autoload/powerup_manager.gd"  # 新規追加
    HazardManager="*res://autoload/hazard_manager.gd"    # 新規追加
    ComboManager="*res://autoload/combo_manager.gd"      # 新規追加
    ```
  - 注意: `*` プレフィックスは必須（シングルトン）
- **検証方法**:
  - Godotエディタを再起動
  - スクリプトエディタで `BossManager.spawn_boss()` が補完されること
- **見積もり時間**: 5分
- **依存タスク**: Phase 1全タスク完了
- **参照ドキュメント**: `design.md` 9.2節（1458-1462行目）

---

### Phase 2-2: 入力マップに use_skill を追加

- [ ] **タスク**: `project.godot` に入力アクション追加
- **詳細説明**:
  - Godotエディタ: プロジェクト設定 > Input Map タブ
  - 新規アクション追加:
    - アクション名: `use_skill`
    - キー割り当て1: `Space`
    - キー割り当て2: `Shift`（左右どちらでも可）
  - デッドゾーン: 0.5（デフォルト）
- **検証方法**:
  - Input Mapで `use_skill` が表示されること
  - テストシーンで `Input.is_action_pressed("use_skill")` が動作すること
- **見積もり時間**: 5分
- **依存タスク**: なし
- **参照ドキュメント**: `design.md` 9.2節（1462行目）、`requirements.md` 3節（76-80行目）

---

## Phase 3: 既存スクリプト修正（優先度: 高）

**推定時間**: 30分
**依存**: Phase 2完了
**目的**: 既存システムへの新メカニクス統合

### Phase 3-1: Player.gd の collect_exp() 修正

- [ ] **タスク**: コンボ倍率を経験値に適用
- **詳細説明**:
  - ファイルパス: `scripts/player/player.gd`
  - `collect_exp()` メソッドを修正:
    ```gdscript
    func collect_exp(amount: int) -> void:
        DebugConfig.log_trace("Player", "collect_exp() called - amount: %d" % amount)

        if amount <= 0:
            push_warning("collect_exp: amount <= 0")
            return

        # コンボ倍率を適用（1行追加）
        var multiplier = ComboManager.get_exp_multiplier()
        var final_amount = int(amount * multiplier)

        DebugConfig.log_debug("Player", "経験値獲得: %d (倍率: %.1fx)" % [final_amount, multiplier])

        var leveled_up = LevelSystem.add_exp(final_amount)

        # 経験値取得音
        AudioManager.play_sfx("pickup", -12.0)

        # レベルアップした場合はGameManagerに通知
        if leveled_up:
            DebugConfig.log_info("Player", "Level up! Changing state to UPGRADE")
            AudioManager.play_sfx("levelup", -5.0)
            _spawn_level_up_effect()
            GameManager.change_state(GameManager.GameState.UPGRADE)
    ```
- **検証方法**:
  - ゲーム実行後、敵を連続撃破して経験値倍率が適用されること
  - ログに "経験値獲得: X (倍率: Y.Yx)" が表示されること
- **見積もり時間**: 5分
- **依存タスク**: Phase 2-1完了
- **参照ドキュメント**: `design.md` 6.2節（1256-1284行目）

---

### Phase 3-2: Enemy.gd の _die() 修正

- [ ] **タスク**: 敵撃破時にコンボ加算
- **詳細説明**:
  - ファイルパス: `scripts/enemies/enemy.gd`
  - `_die()` メソッドに1行追加:
    ```gdscript
    func _die() -> void:
        # コンボ加算（新規追加）
        ComboManager.add_combo()

        died.emit(self)
        _drop_exp()
        PoolManager.return_to_pool(self)

        if GameManager.game_stats != null:
            GameManager.game_stats.add_kill()
    ```
- **検証方法**:
  - ゲーム実行後、敵を倒すとコンボカウントが増加すること
  - ComboDisplayが表示されること
- **見積もり時間**: 3分
- **依存タスク**: Phase 2-1完了
- **参照ドキュメント**: `design.md` 6.2節（1287-1300行目）

---

### Phase 3-3: Boss.gd の _die() 修正

- [ ] **タスク**: ボス撃破時にコンボ大量加算
- **詳細説明**:
  - ファイルパス: `scripts/bosses/boss.gd`
  - `_die()` メソッドを確認・修正（既に実装済みの可能性あり）:
    ```gdscript
    func _die() -> void:
        # コンボ加算（ボスは10コンボ相当）
        for i in range(10):
            ComboManager.add_combo()

        _spawn_drops()
        died.emit()

        # グループから削除
        remove_from_group("enemies")
        queue_free()
    ```
- **検証方法**:
  - ボス撃破時にコンボが+10されること
- **見積もり時間**: 3分
- **依存タスク**: Phase 2-1完了
- **参照ドキュメント**: `design.md` 2.1節（191-212行目）

---

### Phase 3-4: powerup_icon.gd を新規作成

- [ ] **タスク**: PowerupIconのスクリプトを新規作成
- **詳細説明**:
  - ファイルパス: `scripts/ui/powerup_icon.gd`（新規ファイル）
  - 完全コードを作成:
    ```gdscript
    # scripts/ui/powerup_icon.gd
    extends HBoxContainer

    @onready var icon_label: Label = $IconLabel
    @onready var timer_label: Label = $TimerLabel

    var powerup_name: String = ""

    func setup(name: String) -> void:
        powerup_name = name

        # アイコン表示（仮実装: 最初の2文字）
        icon_label.text = name.substr(0, 2).to_upper()

        # 色設定
        match powerup_name:
            "invincibility":
                modulate = Color.YELLOW
            "double_damage":
                modulate = Color.RED
            "speed_boost":
                modulate = Color.CYAN
            "magnet":
                modulate = Color.GREEN

    func update_timer(remaining: float) -> void:
        timer_label.text = "%.1fs" % remaining

        # 残り2秒以下で点滅
        if remaining <= 2.0:
            modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.01)
        else:
            modulate.a = 1.0
    ```
- **検証方法**:
  - スクリプトに構文エラーがないこと
  - Phase 1-8で作成したシーンにアタッチ可能であること
- **見積もり時間**: 10分
- **依存タスク**: Phase 1-8完了
- **参照ドキュメント**: `design.md` 3.4節（863-897行目）

---

## Phase 4: GameScene統合（優先度: 高）

**推定時間**: 30分
**依存**: Phase 3完了
**目的**: UIをゲームシーンに配置

### Phase 4-1: GameScene にUI要素を配置

- [ ] **タスク**: `scenes/game.tscn` に4つのUI要素を追加
- **詳細説明**:
  - Godotエディタで `scenes/game.tscn` を開く
  - UILayerノードの下に以下を追加:
    ```
    UILayer (CanvasLayer)
    ├── HUD.tscn（既存）
    ├── UpgradePanel.tscn（既存）
    ├── GameOverScreen.tscn（既存）
    ├── BossHealthBar.tscn（新規追加 - scenes/ui/boss_health_bar.tscn）
    ├── PowerupTimerDisplay.tscn（新規追加 - scenes/ui/powerup_timer_display.tscn）
    ├── SkillCooldownDisplay.tscn（新規追加 - scenes/ui/skill_cooldown_display.tscn）
    └── ComboDisplay.tscn（新規追加 - scenes/ui/combo_display.tscn）
    ```
  - 配置場所:
    - BossHealthBar: 画面上部中央
    - PowerupTimerDisplay: 画面右上
    - SkillCooldownDisplay: 画面下部中央
    - ComboDisplay: 画面上部中央（BossHealthBarより上）
  - 全てのUI要素の `process_mode` を `PROCESS_MODE_ALWAYS` に設定（重要）
- **検証方法**:
  - GameSceneをF5実行し、全UIが正しい位置に表示されること
  - ポーズ中もUIが動作すること
- **見積もり時間**: 30分
- **依存タスク**: Phase 1（全シーン作成）、Phase 3-4完了
- **参照ドキュメント**: `design.md` 9.2節（1494-1501行目）

---

## Phase 5: 統合テスト（優先度: 高）

**推定時間**: 1-2時間
**依存**: Phase 4完了
**目的**: 全システムの動作確認

### Phase 5-1: ボスバトル基本フロー確認

- [ ] **タスク**: ボスの出現→撃破を確認
- **詳細説明**:
  - ゲームを起動し、20秒後にボスが出現すること
  - BossHealthBarが表示されること
  - ボスが攻撃パターンを実行すること
  - ボスを撃破すると経験値オーブが20個ドロップすること
  - ボス撃破後、3分後に次のボスが出現すること
- **検証項目**:
  - [ ] 3種のボス（Tank、Sniper、Swarm）が全て出現する
  - [ ] フェーズ2移行（HP50%以下）が動作する
  - [ ] ボス撃破音が再生される
  - [ ] BossHealthBarがフェードアウトする
- **見積もり時間**: 20分
- **依存タスク**: Phase 4-1完了
- **参照ドキュメント**: `design.md` 2節

---

### Phase 5-2: パワーアップシステム確認

- [ ] **タスク**: 5種のパワーアップ動作確認
- **詳細説明**:
  - ゲーム開始後10秒でパワーアップが出現すること
  - 5種類全てを拾って効果を確認:
    1. Invincibility: 15秒間無敵（黄色いオーラ）
    2. Double Damage: 15秒間攻撃力2倍（赤いオーラ）
    3. Speed Boost: 12秒間移動速度2倍（青い残像）
    4. Magnet: 15秒間経験値吸引範囲3倍（緑のオーラ）
    5. Screen Clear: 即座に画面上の全敵を撃破（金色の爆発）
- **検証項目**:
  - [ ] PowerupTimerDisplayにアイコンとタイマーが表示される
  - [ ] 効果時間終了時にアイコンが消える
  - [ ] 複数のパワーアップを同時に持てる
  - [ ] パワーアップが10秒後に消える（点滅エフェクト）
- **見積もり時間**: 25分
- **依存タスク**: Phase 4-1完了
- **参照ドキュメント**: `design.md` 3節、`requirements.md` 2節

---

### Phase 5-3: スキルシステム確認

- [ ] **タスク**: 4種のスキル動作確認
- **詳細説明**:
  - ゲーム開始時にランダムでスキルが選択されること
  - Spaceキーでスキル発動すること
  - 4種類を個別に確認（複数回実行して全種を確認）:
    1. Dash: 150px移動、無敵時間0.3秒、CD 5秒
    2. Nova Blast: 範囲攻撃（半径200px、ダメージ100）、CD 10秒
    3. Shield: 3秒間無敵、CD 15秒
    4. Time Slow: 5秒間敵の移動速度50%減少、CD 20秒
- **検証項目**:
  - [ ] SkillCooldownDisplayにスキルアイコンが表示される
  - [ ] クールダウン中は使用不可（グレーアウト）
  - [ ] スキル使用音が再生される
  - [ ] 視覚エフェクトが表示される
- **見積もり時間**: 20分
- **依存タスク**: Phase 4-1完了
- **参照ドキュメント**: `design.md` 4節、`requirements.md` 3節

---

### Phase 5-4: ハザードシステム確認

- [ ] **タスク**: 4種のハザード動作確認
- **詳細説明**:
  - ゲーム開始後15-30秒でハザードが出現すること
  - 警告表示（1秒間）→発動の流れを確認
  - 4種類全てを確認:
    1. Lava Pool: 毎秒10ダメージ、8秒持続
    2. Poison Cloud: 毎秒5ダメージ、12秒持続
    3. Lightning Strike: 即座に100ダメージ、警告1秒
    4. Ice Patch: ダメージなし、移動速度50%減少、10秒持続
- **検証項目**:
  - [ ] 警告表示が1秒間表示される
  - [ ] プレイヤーと敵の両方がダメージを受ける
  - [ ] ハザードが最大5個まで同時出現する
  - [ ] パーティクルエフェクトが表示される
- **見積もり時間**: 20分
- **依存タスク**: Phase 4-1完了
- **参照ドキュメント**: `design.md` 5節、`requirements.md` 4節

---

### Phase 5-5: コンボシステム確認

- [ ] **タスク**: コンボ連鎖と経験値ボーナス確認
- **詳細説明**:
  - 敵を連続撃破してコンボが増加すること
  - ComboDisplayが表示されること
  - 3秒間撃破がないとコンボが途切れること
  - コンボボーナスが適用されること:
    - 10コンボ: 経験値 +10%
    - 20コンボ: 経験値 +20%
    - 50コンボ: 経験値 +50%
    - 100コンボ: 経験値 +100%
- **検証項目**:
  - [ ] コンボカウントが正しく表示される
  - [ ] コンボ10以上で文字が金色になる
  - [ ] コンボ50以上で文字が虹色になる
  - [ ] タイマーバーがカウントダウンする
  - [ ] コンボ途切れ時にフェードアウトする
- **見積もり時間**: 15分
- **依存タスク**: Phase 3-1、3-2、3-3完了
- **参照ドキュメント**: `design.md` 6節、`requirements.md` 5節

---

## Phase 6: バランス調整（優先度: 中）

**推定時間**: 1時間
**依存**: Phase 5完了
**目的**: ゲームバランスの微調整

### Phase 6-1: スポーン間隔調整

- [ ] **タスク**: ボス・パワーアップ・ハザードの出現間隔を調整
- **詳細説明**:
  - 以下のAutoloadファイルを編集:
    - `autoload/boss_manager.gd`: `BOSS_SPAWN_INTERVAL`（現在180秒）
    - `autoload/powerup_manager.gd`: `SPAWN_INTERVAL`（現在45秒）
    - `autoload/hazard_manager.gd`: `SPAWN_INTERVAL`（現在20秒）
  - プレイテストを繰り返し、最適な値を見つける
  - 推奨範囲:
    - ボス: 120-240秒
    - パワーアップ: 30-60秒
    - ハザード: 15-30秒
- **検証方法**:
  - 10分間プレイして、出現頻度が適切であること
  - プレイヤーが暇を感じず、かつ圧倒されないこと
- **見積もり時間**: 30分
- **依存タスク**: Phase 5全タスク完了
- **参照ドキュメント**: `design.md` 2.3節、3.2節、5.2節

---

### Phase 6-2: コンボ倍率調整

- [ ] **タスク**: コンボボーナスの倍率を調整
- **詳細説明**:
  - `autoload/combo_manager.gd` を編集
  - `get_exp_multiplier()` の倍率テーブルを調整:
    ```gdscript
    func get_exp_multiplier() -> float:
        if current_combo >= 100:
            return 2.0  # 調整候補: 1.5-3.0
        elif current_combo >= 50:
            return 1.5  # 調整候補: 1.3-2.0
        elif current_combo >= 20:
            return 1.2  # 調整候補: 1.15-1.5
        elif current_combo >= 10:
            return 1.1  # 調整候補: 1.05-1.2
        else:
            return 1.0
    ```
  - プレイテストを繰り返し、経験値獲得が早すぎ/遅すぎないか確認
- **検証方法**:
  - コンボを維持することにメリットがあること
  - 100コンボ達成が不可能ではないこと
- **見積もり時間**: 20分
- **依存タスク**: Phase 5-5完了
- **参照ドキュメント**: `design.md` 6.1節、`requirements.md` 5節

---

### Phase 6-3: パフォーマンス最適化

- [ ] **タスク**: 60FPS維持を確認・最適化
- **詳細説明**:
  - Godotエディタの「デバッグ」→「パフォーマンスモニター」を表示
  - 以下の状況で60FPS維持を確認:
    - ボス1体 + 敵200体 + ハザード5個 + パワーアップエフェクト
  - FPSが60を下回る場合の対策:
    1. CPUParticles2Dの`amount`を減らす（50→30）
    2. ハザード同時出現数を制限（5→3）
    3. 敵の数を制限（PoolManager.max_pool_size調整）
  - プロファイラで重い処理を特定
- **検証方法**:
  - 5分間プレイしてFPSが常に55以上であること
  - 処理時間が16.6ms（60FPS）を超えないこと
- **見積もり時間**: 30分
- **依存タスク**: Phase 5全タスク完了
- **参照ドキュメント**: `design.md` 11節（1520-1552行目）、`requirements.md` 技術要件

---

## リスク管理

### 高リスク（発生可能性: 中、影響度: 高）

1. **シーンファイル作成ミス**
   - リスク: ノード構成が不正確で実行時エラー
   - 対策: Phase 1各タスクで単体実行テスト必須
   - 軽減策: design.mdの推奨ノード構成を厳密に守る

2. **Autoload登録忘れ**
   - リスク: BossManager等がnullでクラッシュ
   - 対策: Phase 2-1完了後に必ずエディタ再起動
   - 軽減策: スクリプトエディタで補完が効くか確認

3. **パフォーマンス低下**
   - リスク: ボス+敵+ハザード同時出現で60FPS割れ
   - 対策: Phase 6-3で早期にプロファイリング
   - 軽減策: CPUParticles2Dのamountを保守的に設定（50以下）

### 中リスク（発生可能性: 低、影響度: 中）

4. **UI配置ミス**
   - リスク: UIが重なって視認性低下
   - 対策: Phase 4-1でアンカー設定を慎重に
   - 軽減策: 画面解像度1920x1080でテスト

5. **コンボ倍率バランス崩壊**
   - リスク: 経験値が早く入りすぎて難易度崩壊
   - 対策: Phase 6-2でプレイテスト反復
   - 軽減策: 倍率を保守的に開始（1.1/1.2/1.5/2.0）

### 低リスク（発生可能性: 低、影響度: 低）

6. **スキル選択のランダム性**
   - リスク: 特定のスキルが出現しない
   - 対策: Phase 5-3で全種確認（複数回実行）
   - 軽減策: 将来的にスキル選択画面を実装

---

## 完了条件

### Phase 1完了条件
- [ ] 全10シーンファイルが作成され、Godotエディタでエラーなく開ける
- [ ] 各シーンを単体実行（F6）してもクラッシュしない

### Phase 2完了条件
- [ ] Autoloadが4つ登録され、スクリプトエディタで補完が効く
- [ ] 入力マップに `use_skill` が登録され、テスト可能

### Phase 3完了条件
- [ ] 既存スクリプト4ファイルが修正され、構文エラーがない
- [ ] Git diffで変更箇所が設計通りであること

### Phase 4完了条件
- [ ] GameSceneに全UI要素が配置され、レイアウトが正しい
- [ ] GameSceneをF5実行してエラーログがない

### Phase 5完了条件
- [ ] 全5項目のテストが合格（ボス・パワーアップ・スキル・ハザード・コンボ）
- [ ] 致命的なバグが存在しない
- [ ] 60FPSで動作する

### Phase 6完了条件
- [ ] スポーン間隔・コンボ倍率が調整され、プレイテストで妥当と判断
- [ ] パフォーマンスモニターで60FPS維持を確認

### プロジェクト全体完了条件
- [ ] Phase 1-6の全タスクが完了
- [ ] `requirements.md` の全受け入れ条件が満たされている
- [ ] プレイテストで「成功の定義」が達成されている
- [ ] 既存システム（Pattern A+B）との共存が確認されている

---

## 次のステップ

### 今すぐ開始すべきタスク
**Phase 1-1**: Tank Boss シーン作成（推定時間: 20分）

### Phase 1完了後の確認事項
1. 全シーンファイルがGit管理されていること
2. 各シーンのスクリプトアタッチが正しいこと
3. エクスポート変数がインスペクタで設定されていること

### Phase 5完了後のレビュー項目
1. 新メカニクスが既存ゲームプレイを損なっていないか
2. UIが視認性を損なっていないか
3. パフォーマンスが許容範囲か（55FPS以上）

### Phase 6完了後のドキュメント更新
- `docs/functional-design.md` に新メカニクスの詳細を統合（必要に応じて）
- `CHANGELOG.md` にPhase C完了を記録
- `.steering/20250227-new-mechanics/tasklist.md` に最終結果を記載

---

## 参照ドキュメント

- **要求定義**: `.steering/20250227-new-mechanics/requirements.md`
- **実装設計**: `.steering/20250227-new-mechanics/design.md`
- **既存システム設計**: `docs/functional-design.md`
- **開発プロセス**: `CLAUDE.md`

---

**作成者**: Claude (AI Assistant)
**最終更新**: 2026-02-27
