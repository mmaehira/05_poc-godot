# development-guidelines.md
開発ガイドライン

---

# 1. コーディング規約

## 1.1 GDScript スタイルガイド

### 基本原則
[Godot公式スタイルガイド](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)に準拠

### インデント
- **タブではなくスペース4つ**
```gdscript
# 正しい
func example() -> void:
    if condition:
        do_something()

# 誤り（タブ使用）
func example() -> void:
→   if condition:
→   →   do_something()
```

### 命名規則
| 対象 | 規則 | 例 |
|------|------|-----|
| クラス名 | PascalCase | `Player`, `WeaponInstance` |
| ファイル名 | snake_case | `player.gd`, `weapon_instance.gd` |
| 関数名 | snake_case | `add_exp()`, `spawn_enemy()` |
| 変数名 | snake_case | `current_hp`, `max_weapons` |
| 定数名 | SCREAMING_SNAKE_CASE | `MAX_HP`, `BASE_SPEED` |
| シグナル名 | snake_case | `level_up`, `hp_changed` |
| プライベート変数 | 先頭に`_` | `_internal_state` |

### 型アノテーション（必須）
```gdscript
# 変数の型指定
var current_hp: int = 100
var weapon_data: Weapon = null
var enemy_list: Array[Node] = []

# 関数の型指定
func add_exp(amount: int) -> void:
    experience += amount

func get_player() -> Node:
    return player_node
```

---

## 1.2 コード構造

### クラス定義の順序
```gdscript
class_name Player extends CharacterBody2D

# 1. クラスドキュメント
## プレイヤークラス
##
## 責務:
## - 移動入力の処理
## - HP管理
## - 経験値オーブの回収

# 2. シグナル
signal hp_changed(new_hp: int)
signal died()

# 3. 定数
const MAX_HP: int = 100
const BASE_SPEED: float = 200.0

# 4. @export変数
@export var speed: float = BASE_SPEED
@export var max_hp: int = MAX_HP

# 5. 公開変数
var current_hp: int = max_hp

# 6. プライベート変数
var _velocity: Vector2 = Vector2.ZERO

# 7. @onready変数
@onready var weapon_manager: WeaponManager = $WeaponManager
@onready var sprite: Sprite2D = $Sprite2D

# 8. ライフサイクル関数（_ready, _process等）
func _ready() -> void:
    current_hp = max_hp

func _process(delta: float) -> void:
    _handle_input(delta)

# 9. 公開メソッド
func take_damage(amount: int) -> void:
    current_hp -= amount
    hp_changed.emit(current_hp)
    if current_hp <= 0:
        died.emit()

# 10. プライベートメソッド
func _handle_input(delta: float) -> void:
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = direction * speed
```

---

## 1.3 コメント規約

### クラスドキュメント
```gdscript
## WeaponInstanceクラス
##
## 武器の実体を管理するNodeクラス。
## Weapon Resourceからデータを読み込み、実際の攻撃処理を実行する。
##
## 依存:
## - owner_player: 武器を所持するプレイヤー
## - weapon_data: 武器の基礎データ（Resource）
##
## 使用例:
## [codeblock]
## var weapon_instance = WeaponInstance.new()
## weapon_instance.initialize(weapon_data, 1, player)
## [/codeblock]
class_name WeaponInstance extends Node
```

### 関数ドキュメント
```gdscript
## 経験値を追加し、レベルアップ判定を行う
##
## @param amount: 追加する経験値量
## @return: レベルアップした場合true
func add_exp(amount: int) -> bool:
    if amount <= 0:
        push_warning("add_exp: 経験値量が0以下です amount=%d" % amount)
        return false

    experience += amount
    return _check_level_up()
```

### インラインコメント
```gdscript
# 悪い例: 自明なコメント
var hp: int = 100  # HPを100に設定

# 良い例: 理由を説明
var hp: int = 100  # テストモードでは初期HP固定
```

---

# 2. Godot固有のベストプラクティス

## 2.1 シーン設計

### シーンの粒度
- **1シーン = 1責務**
- ノード数は50個以下を目安
- 複雑な場合はサブシーンに分割

### シーンの再利用性
```
# 良い例: 敵をシーンとして独立
scenes/enemies/basic_enemy.tscn  # 独立したシーン
scenes/game.tscn  # basic_enemyをインスタンス化

# 悪い例: 敵をgame.tscnに直接配置
scenes/game.tscn
  └─ BasicEnemy (ここに直接配置)
```

---

## 2.2 ノードツリー設計

### process_mode設定
```gdscript
# GameManager.change_state()でポーズ制御
func change_state(new_state: GameState) -> void:
    match new_state:
        GameState.PAUSED, GameState.UPGRADE:
            get_tree().paused = true
        GameState.PLAYING:
            get_tree().paused = false

# UIはポーズ中も動作
@onready var upgrade_panel: Control = $UpgradePanel
func _ready() -> void:
    upgrade_panel.process_mode = Node.PROCESS_MODE_ALWAYS

# ゲームオブジェクトはポーズ可能
@onready var player: Player = $Player
func _ready() -> void:
    player.process_mode = Node.PROCESS_MODE_PAUSABLE
```

### ノードパスの取得
```gdscript
# 悪い例: 相対パス依存
var enemy = get_parent().get_parent().get_node("Enemy")

# 良い例: @onready
@onready var enemy: Enemy = $Enemy

# 良い例: 参照を直接渡す
func initialize(player: Node) -> void:
    owner_player = player
```

---

## 2.3 Resource活用

### データ駆動設計
```gdscript
# resources/weapon.gd
class_name Weapon extends Resource

@export var weapon_name: String = ""
@export var base_damage: int = 10
@export var attack_interval: float = 1.0
@export var attack_type: AttackType = AttackType.STRAIGHT_SHOT

enum AttackType {
    STRAIGHT_SHOT,
    AREA_BLAST,
    HOMING_MISSILE
}
```

### .tresファイル作成
```
# Godotエディタでの作成手順
1. resources/weapons/straight_shot.tres を新規作成
2. 型を Weapon に設定
3. パラメータを設定:
   - weapon_name: "直線ショット"
   - base_damage: 10
   - attack_interval: 0.5
   - attack_type: STRAIGHT_SHOT
```

---

## 2.4 Signal活用

### Signal命名と使用
```gdscript
# シグナル定義
signal level_up(new_level: int, choices: Array[Dictionary])
signal hp_changed(new_hp: int, max_hp: int)

# シグナル発火
func _level_up() -> void:
    current_level += 1
    var choices = _generate_choices()
    level_up.emit(current_level, choices)

# シグナル接続（型安全）
func _ready() -> void:
    LevelSystem.level_up.connect(_on_level_up)

func _on_level_up(new_level: int, choices: Array[Dictionary]) -> void:
    print("レベルアップ: Lv.%d" % new_level)
```

### Signal使用ガイドライン
- **下位→上位の通知**: Signalを使用
- **上位→下位の命令**: 直接メソッド呼び出し
- **同レイヤー**: 極力避ける（疎結合維持）

---

## 2.5 Autoload使用方針

### Autoload制限
- **MVP時点**: GameManager, LevelSystem, PoolManagerの3つのみ
- **将来的**: Logger追加可能だが最小限に抑える

### Autoloadアクセス
```gdscript
# 正しい: Autoloadへの直接アクセス
LevelSystem.add_exp(10)
GameManager.change_state(GameManager.GameState.PAUSED)

# 誤り: Autoloadの過度な責務
# AutoloadにUI操作ロジックを書かない
# Autoloadに個別のゲームオブジェクト操作を書かない
```

---

# 3. パフォーマンスガイドライン

## 3.1 オブジェクトプール

### PoolManager使用
```gdscript
# 敵のスポーン
var enemy = PoolManager.spawn_enemy(
    "res://scenes/enemies/basic_enemy.tscn",
    spawn_position
)

# 敵の返却（queue_free()は使わない）
PoolManager.return_enemy(enemy)
```

### プール対象
- 敵（Enemy）
- 弾丸（Projectile）
- 経験値オーブ（ExpOrb）

### プール非対象
- プレイヤー（1体のみ）
- UI要素（永続的）

---

## 3.2 _process最適化

### デルタタイム活用
```gdscript
func _process(delta: float) -> void:
    # 正しい: デルタタイムで補正
    position += velocity * delta

# 誤り: デルタタイムなし
func _process(delta: float) -> void:
    position += velocity  # フレームレート依存
```

### 処理の間引き
```gdscript
var _update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.1  # 100ms毎

func _process(delta: float) -> void:
    _update_timer += delta
    if _update_timer >= UPDATE_INTERVAL:
        _update_timer = 0.0
        _expensive_update()
```

---

## 3.3 メモリ管理

### 参照の解放
```gdscript
func _exit_tree() -> void:
    # シグナル接続解除
    if LevelSystem.level_up.is_connected(_on_level_up):
        LevelSystem.level_up.disconnect(_on_level_up)

    # 参照クリア
    owner_player = null
    weapon_data = null
```

### 循環参照の回避
```gdscript
# 悪い例: 循環参照
class_name Parent extends Node
var child: Child = null

class_name Child extends Node
var parent: Parent = null  # 循環参照

# 良い例: WeakRefまたは片方向参照
class_name Child extends Node
var parent: WeakRef = null  # WeakRefで循環回避
```

---

# 4. エラーハンドリング

## 4.1 エラー分類と対応

### Critical（致命的エラー）
```gdscript
func spawn_enemy(scene_path: String, position: Vector2) -> Node:
    if not ResourceLoader.exists(scene_path):
        push_error("spawn_enemy: シーンが存在しません path=%s" % scene_path)
        return null  # nullを返してクラッシュ回避

    var scene = load(scene_path)
    if scene == null:
        push_error("spawn_enemy: シーンのロードに失敗 path=%s" % scene_path)
        return null

    return scene.instantiate()
```

### Warning（警告）
```gdscript
func add_weapon(weapon: Weapon) -> bool:
    if weapons.size() >= MAX_WEAPONS:
        push_warning("add_weapon: 武器スロット上限 current=%d max=%d" % [weapons.size(), MAX_WEAPONS])
        return false

    weapons.append(weapon)
    return true
```

### Info（情報）
```gdscript
func _on_level_up(new_level: int) -> void:
    print("レベルアップ: Lv.%d (経験値: %d/%d)" % [new_level, experience, next_level_exp])
```

---

## 4.2 nullチェック

### 必須チェック箇所
```gdscript
func attack() -> void:
    if owner_player == null:
        push_error("attack: owner_playerがnullです")
        return

    if weapon_data == null:
        push_error("attack: weapon_dataがnullです")
        return

    _execute_attack()
```

### @onready変数の安全性
```gdscript
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    if sprite == null:
        push_error("Sprite2Dノードが見つかりません")
        return

    sprite.texture = load("res://assets/sprites/player/idle.png")
```

---

## 4.3 境界値チェック

### 配列アクセス
```gdscript
func get_weapon(index: int) -> Weapon:
    if index < 0 or index >= weapons.size():
        push_warning("get_weapon: インデックス範囲外 index=%d size=%d" % [index, weapons.size()])
        return null

    return weapons[index]
```

### 数値範囲
```gdscript
func set_hp(value: int) -> void:
    current_hp = clampi(value, 0, max_hp)  # 0～max_hpに制限
    hp_changed.emit(current_hp)
```

---

# 5. テスト方針

## 5.1 手動テスト（MVP時点）

### テストチェックリスト
```markdown
## 基本動作
- [ ] プレイヤー移動（WASD/矢印キー）
- [ ] 武器自動攻撃
- [ ] 敵のスポーンと追跡
- [ ] 経験値オーブの回収
- [ ] レベルアップと3択UI

## パフォーマンス
- [ ] 敵200体同時でFPS 30以上
- [ ] 弾丸500発同時でFPS 30以上
- [ ] 15分プレイでメモリ512MB以下

## エラーハンドリング
- [ ] 武器6個所持時の動作
- [ ] 敵プール上限到達時の動作
- [ ] ポーズ中の入力遮断
```

---

## 5.2 デバッグツール

### performance_monitor.gd（将来的）
```gdscript
# scripts/debug/performance_monitor.gd
extends Node

func _process(delta: float) -> void:
    if not OS.is_debug_build():
        return

    var fps = Engine.get_frames_per_second()
    var memory = OS.get_static_memory_usage() / 1024.0 / 1024.0  # MB

    if fps < 30:
        push_warning("FPS低下: %d" % fps)
    if memory > 512:
        push_warning("メモリ使用量超過: %.1f MB" % memory)
```

### デバッグ出力
```gdscript
const DEBUG_MODE = OS.is_debug_build()

func spawn_enemy(scene_path: String, position: Vector2) -> Node:
    if DEBUG_MODE:
        print("spawn_enemy: path=%s pos=%v" % [scene_path, position])

    # ... 処理 ...
```

---

## 5.3 単体テスト（将来的）

### GUT (Godot Unit Test) 導入
```bash
# addons/gut/ にGUTをインストール
git clone https://github.com/bitwes/Gut.git addons/gut
```

### テスト例
```gdscript
# tests/unit/test_level_system.gd
extends GutTest

func before_each():
    # Autoloadの状態をリセット
    LevelSystem.reset()

func test_add_exp_increases_experience():
    LevelSystem.experience = 0

    LevelSystem.add_exp(10)

    assert_eq(LevelSystem.experience, 10, "経験値が増加する")

func test_level_up_when_exp_reaches_threshold():
    LevelSystem.current_level = 1
    LevelSystem.experience = 0
    LevelSystem.next_level_exp = 10

    var leveled_up = LevelSystem.add_exp(10)

    assert_true(leveled_up, "レベルアップする")
    assert_eq(LevelSystem.current_level, 2, "レベルが2になる")

# 注意: Autoloadはシングルトンのため、テスト間で状態が共有される
# before_each()で必ず reset() を呼び出すこと
```

---

# 6. Git運用ガイドライン

## 6.1 ブランチ戦略（将来的）

### ブランチ種類
- **main**: 安定版（動作保証）
- **dev**: 開発ブランチ（統合）
- **feature/xxx**: 機能追加
- **fix/xxx**: バグ修正

### ブランチ命名
```bash
# 機能追加
git checkout -b feature/add-boss-battle

# バグ修正
git checkout -b fix/player-collision-bug

# リファクタリング
git checkout -b refactor/weapon-system
```

---

## 6.2 コミット規約

### コミットメッセージ形式
```
[種類] 簡潔な変更内容（50文字以内）

詳細説明（必要に応じて）
- 変更理由
- 影響範囲
- 注意事項

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 種類プレフィックス
| プレフィックス | 用途 | 例 |
|--------------|------|-----|
| `feat` | 新機能追加 | `feat: ボス戦システム実装` |
| `fix` | バグ修正 | `fix: プレイヤー衝突判定の修正` |
| `docs` | ドキュメント | `docs: architecture.md更新` |
| `refactor` | リファクタリング | `refactor: WeaponInstance分離` |
| `perf` | パフォーマンス改善 | `perf: 敵スポーン処理最適化` |
| `test` | テスト追加 | `test: LevelSystem単体テスト` |
| `chore` | ビルド・設定 | `chore: .gitignore更新` |

### コミット例
```
feat: 経験値オーブのオブジェクトプール実装

PoolManagerにexp_orbプールを追加し、
queue_free()の使用を廃止。

- spawn_exp_orb() / return_exp_orb() 実装
- LRU方式での上限管理（200個）
- functional-design.mdのSection 15と整合

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## 6.3 コミット粒度

### 適切な粒度
```bash
# 良い例: 1機能1コミット
git commit -m "feat: 直線ショット武器実装"
git commit -m "feat: 範囲爆発武器実装"

# 悪い例: 複数機能を1コミット
git commit -m "feat: 武器システム全部実装"
```

### コミットタイミング
- 機能単位で完成したらコミット
- テストが通ったらコミット
- ドキュメント更新とセットでコミット

---

# 7. コードレビューガイドライン（将来的）

## 7.1 レビュー観点

### 機能性
- [ ] 要件を満たしているか
- [ ] エッジケースを考慮しているか
- [ ] エラーハンドリングは適切か

### 可読性
- [ ] 命名規則に従っているか
- [ ] コメントは適切か
- [ ] 複雑な処理は分割されているか

### パフォーマンス
- [ ] オブジェクトプールを使用しているか
- [ ] 不要な_process呼び出しはないか
- [ ] メモリリークの可能性はないか

### 保守性
- [ ] 既存コードとの整合性
- [ ] 拡張性は確保されているか
- [ ] ドキュメントは更新されているか

---

## 7.2 レビューコメント例

### 良いコメント
```
# 具体的な指摘
> null チェックが必要です。weapon_data が null の場合、
> line 42 でクラッシュします。

> この処理は _process で毎フレーム実行されますが、
> 0.1秒毎の間引きで十分ではないでしょうか？
```

### 避けるべきコメント
```
# 抽象的すぎる
> ここが良くないです

# 否定的すぎる
> このコードはダメです
```

---

# 8. リファクタリングガイドライン

## 8.1 リファクタリングの判断基準

### リファクタリング対象
- 関数が200行を超える
- ネストが4階層以上
- 同じコードが3箇所以上に出現
- クラスの責務が曖昧

### リファクタリング手法
```gdscript
# Before: 長大な関数
func _process(delta: float) -> void:
    # 入力処理（30行）
    var direction = Input.get_vector(...)
    # ...
    # 移動処理（20行）
    velocity = direction * speed
    # ...
    # 攻撃処理（40行）
    if can_attack:
        # ...

# After: 責務分割
func _process(delta: float) -> void:
    _handle_input(delta)
    _handle_movement(delta)
    _handle_attack(delta)

func _handle_input(delta: float) -> void:
    # 入力処理のみ

func _handle_movement(delta: float) -> void:
    # 移動処理のみ

func _handle_attack(delta: float) -> void:
    # 攻撃処理のみ
```

---

## 8.2 段階的リファクタリング

### 手順
1. **既存コードの理解**: 動作を確認
2. **テストの追加**: リグレッション防止
3. **小さな変更**: 1つずつ変更
4. **動作確認**: 各変更後にテスト
5. **コミット**: 変更が安全だったらコミット

### 例
```bash
# Step 1: 現状の動作確認
git checkout -b refactor/weapon-system

# Step 2: Weapon Resource化
# ... 変更 ...
# テストプレイで動作確認

git commit -m "refactor: WeaponをResource化"

# Step 3: WeaponInstance分離
# ... 変更 ...
# テストプレイで動作確認

git commit -m "refactor: WeaponInstance分離"
```

---

# 9. ドキュメント更新ガイドライン

## 9.1 ドキュメント種類と更新タイミング

### 永続的ドキュメント（docs/）
| ファイル | 更新タイミング |
|---------|-------------|
| product-requirements.md | プロダクト方針変更時 |
| functional-design.md | 設計変更時 |
| architecture.md | 技術選択変更時 |
| repository-structure.md | ディレクトリ構造変更時 |
| development-guidelines.md | 開発ルール変更時 |
| glossary.md | 用語追加時 |

### 作業ドキュメント（.steering/）
| ファイル | 更新タイミング |
|---------|-------------|
| requirements.md | 作業開始時（作成） |
| design.md | 設計時（作成） |
| tasklist.md | タスク完了時（更新） |

---

## 9.2 ドキュメント更新フロー

### 設計変更が発生した場合
```bash
# 1. .steering/ に作業ドキュメント作成
mkdir -p .steering/20260226-add-boss-battle
vim .steering/20260226-add-boss-battle/requirements.md

# 2. 設計がfunctional-designに影響する場合
vim docs/functional-design.md  # Section追加 or 修正

# 3. 実装
vim scripts/bosses/boss.gd

# 4. ドキュメント更新をコミット
git add docs/functional-design.md
git commit -m "docs: ボス戦システム設計追加"

# 5. 実装をコミット
git add scripts/bosses/
git commit -m "feat: ボス戦システム実装"
```

---

# 10. 開発環境セットアップ

## 10.1 必須ツール

### Godot Engine 4.3
```bash
# Devcontainer内に既にインストール済み
godot --version
# Godot Engine v4.3.stable.official
```

### VSCode拡張機能
- **Claude Code**: AI支援開発（インストール済み）
- **Godot Tools**: GDScriptシンタックス（推奨）
```bash
# VSCode拡張インストール
code --install-extension geequlim.godot-tools
```

---

## 10.2 プロジェクト初回セットアップ

### 手順
```bash
# 1. リポジトリクローン
git clone <repository-url> 05_poc-godot
cd 05_poc-godot

# 2. Godotプロジェクト初期化
godot --editor

# 3. Autoload設定（Godotエディタ）
# プロジェクト設定 > Autoload
# - GameManager: res://autoload/game_manager.gd
# - LevelSystem: res://autoload/level_system.gd
# - PoolManager: res://autoload/pool_manager.gd

# 4. 入力マップ設定（Godotエディタ）
# プロジェクト設定 > 入力マップ
# - ui_left: A, 左矢印
# - ui_right: D, 右矢印
# - ui_up: W, 上矢印
# - ui_down: S, 下矢印
```

---

## 10.3 開発ワークフロー

### 通常の開発フロー
```bash
# 1. 作業ブランチ作成
git checkout -b feature/add-weapon

# 2. .steering/ に作業ドキュメント作成
mkdir -p .steering/20260226-add-weapon
vim .steering/20260226-add-weapon/requirements.md

# 3. 実装
# - Godotエディタでシーン作成
# - VSCodeでスクリプト編集

# 4. テストプレイ
godot --path . scenes/main.tscn

# 5. コミット
git add .
git commit -m "feat: ホーミングミサイル武器実装"

# 6. プッシュ（将来的）
git push origin feature/add-weapon
```

---

# 11. トラブルシューティング

## 11.1 よくあるエラー

### エラー: "Invalid get index 'position' (on base: 'null')"
**原因**: ノード参照がnull

**解決**:
```gdscript
# 修正前
func attack() -> void:
    var target_pos = owner_player.global_position  # owner_playerがnull

# 修正後
func attack() -> void:
    if owner_player == null:
        push_error("attack: owner_playerがnullです")
        return
    var target_pos = owner_player.global_position
```

---

### エラー: "Scene file not found"
**原因**: シーンパスが間違っている

**解決**:
```gdscript
# 修正前
var scene = load("scenes/enemies/basic_enemy.tscn")  # res://が欠落

# 修正後
var scene = load("res://scenes/enemies/basic_enemy.tscn")
```

---

### 問題: FPSが30以下に低下
**原因**: オブジェクト数過多 or 重い処理

**解決**:
```gdscript
# デバッグ出力で原因特定
func _process(delta: float) -> void:
    var active_enemies = PoolManager.get_active_count("enemies")
    var active_projectiles = PoolManager.get_active_count("projectiles")

    if Engine.get_frames_per_second() < 30:
        push_warning("FPS低下: enemies=%d projectiles=%d" % [active_enemies, active_projectiles])
```

---

## 11.2 デバッグテクニック

### print_tree()
```gdscript
func _ready() -> void:
    print_tree_pretty()  # ノードツリー表示
```

### ブレークポイント
```gdscript
func attack() -> void:
    breakpoint  # ここでデバッガ停止
    _execute_attack()
```

### Visual Profiler
```
Godotエディタ > デバッガ > プロファイラ
- FPS測定
- メモリ使用量
- 関数実行時間
```

---

# 12. ベストプラクティスまとめ

## 12.1 コーディング
- ✅ 型アノテーション必須
- ✅ snake_case / PascalCase厳守
- ✅ クラスドキュメント記載
- ✅ nullチェック徹底
- ✅ 境界値チェック

## 12.2 Godot設計
- ✅ シーン粒度は小さく（50ノード以下）
- ✅ Signalで疎結合
- ✅ Resourceでデータ分離
- ✅ Autoloadは3つまで
- ✅ オブジェクトプール活用

## 12.3 パフォーマンス
- ✅ デルタタイムで補正
- ✅ 重い処理は間引き
- ✅ 参照解放を忘れない
- ✅ FPS/メモリ監視

## 12.4 Git運用
- ✅ 機能単位でコミット
- ✅ コミットメッセージ規約
- ✅ ブランチ戦略（将来的）
- ✅ ドキュメント更新も同時

---

# 13. 変更履歴

## 2026-02-26: 初版作成とレビュー修正

### レビュー修正内容
1. **Section 5.3（単体テスト例）修正**
   - **問題**: LevelSystemをnew()でインスタンス化（Autoloadの設計に反する）
   - **修正**: Autoloadを直接参照し、before_each()でreset()を呼び出す方式に変更
   - **理由**: functional-design.mdで定義されたAutoload設計との整合性確保

### 整合性確認済み
- ✅ [architecture.md](architecture.md) - 技術スタック、パフォーマンス要件、ADR
- ✅ [functional-design.md](functional-design.md) - システム設計、Autoload定義
- ✅ [repository-structure.md](repository-structure.md) - ディレクトリ構造、命名規則

---

**開発ガイドライン確定**: 全開発ルールを定義済み（他ドキュメントと整合性確保）
