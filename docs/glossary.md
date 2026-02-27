# glossary.md
ユビキタス言語定義

---

# 1. プロジェクト概要

## 目的
このドキュメントは、プロジェクト全体で使用される用語の統一的な定義を提供します。ドメイン駆動設計（DDD）のユビキタス言語の原則に基づき、開発者、ドキュメント、コード間での用語の一貫性を保証します。

## 使用方針
- コード内のクラス名、変数名、コメントはこの用語集に従う
- 新しい概念が登場した場合、このドキュメントに追加する
- 用語の意味が変わった場合、履歴を残して更新する

---

# 2. ゲームシステム用語

## 2.1 ゲームループ関連

### Game State（ゲーム状態）
**定義**: ゲーム全体の実行状態を表すenum
**英語**: Game State
**日本語**: ゲーム状態
**型**: `GameManager.GameState` (enum)
**値**:
- `TITLE`: タイトル画面
- `PLAYING`: ゲームプレイ中
- `PAUSED`: ポーズ中
- `UPGRADE`: アップグレード選択中
- `GAME_OVER`: ゲームオーバー

**関連**: GameManager, state_changed シグナル

**コード例**:
```gdscript
enum GameState {
    TITLE,
    PLAYING,
    PAUSED,
    UPGRADE,
    GAME_OVER
}
```

---

### Game Stats（ゲーム統計）
**定義**: 1回のゲームプレイセッションの統計情報
**英語**: Game Stats
**日本語**: ゲーム統計
**型**: `GameStats` (Resource)
**プロパティ**:
- `start_time: int` - 開始時刻（ミリ秒）
- `kill_count: int` - 撃破数
- `damage_dealt: int` - 与ダメージ総量
- `damage_taken: int` - 被ダメージ総量

**関連**: GameManager.game_stats

**注意**: Dictionaryではなく型付きResource

---

### MVP（Minimum Viable Product）
**定義**: 実装する最小限の機能範囲
**英語**: MVP
**日本語**: 最小実用製品
**範囲**:
- 単一ステージ（最大15分）
- 武器3種
- 敵2種
- レベルアップ3択
- ゲームオーバー画面

**関連**: product-requirements.md

---

## 2.2 プレイヤー関連

### Player（プレイヤー）
**定義**: ユーザーが操作するキャラクター
**英語**: Player
**日本語**: プレイヤー
**型**: `Player` (CharacterBody2D)
**責務**:
- 移動入力処理
- HP管理
- 経験値オーブ回収（LevelSystemへ委譲）
- WeaponManagerの保持

**禁止事項**:
- 経験値の直接保持（LevelSystemが管理）
- 武器の攻撃ロジック（WeaponInstanceが管理）

**関連**: WeaponManager, LevelSystem

---

### HP（Hit Points / ヒットポイント）
**定義**: プレイヤーの体力
**英語**: HP, Hit Points
**日本語**: ヒットポイント、体力
**型**: `int`
**範囲**: `0 <= current_hp <= max_hp`
**初期値**: MVP時点では`max_hp = 100`

**関連**: Player.current_hp, Player.hp_changed シグナル

---

### Speed（移動速度）
**定義**: プレイヤーの移動速度（ピクセル/秒）
**英語**: Speed
**日本語**: 移動速度
**型**: `float`
**初期値**: `200.0` (ピクセル/秒)
**補正**: アップグレードで増減可能

**関連**: Player.speed, UpgradeType.SPEED

---

## 2.3 経験値・レベル関連

### Experience（経験値）
**定義**: プレイヤーのレベルアップに必要なポイント
**英語**: Experience, EXP
**日本語**: 経験値
**型**: `int`
**管理**: LevelSystem（Autoload）が唯一の管理者

**注意**: Playerクラスには保持しない

**関連**: LevelSystem.experience, ExpOrb

---

### Level（レベル）
**定義**: プレイヤーの成長段階
**英語**: Level
**日本語**: レベル
**型**: `int`
**初期値**: `1`
**計算式**: `next_level_exp = base_exp * (exp_growth_rate ^ (current_level - 1))`
**パラメータ**:
- `base_exp = 10`
- `exp_growth_rate = 1.18`

**関連**: LevelSystem.current_level, level_up シグナル

---

### Level Up（レベルアップ）
**定義**: 経験値が閾値に達し、レベルが上昇するイベント
**英語**: Level Up
**日本語**: レベルアップ
**トリガー**: `experience >= next_level_exp`
**効果**:
- `current_level += 1`
- `experience -= next_level_exp`
- ゲーム状態を`UPGRADE`に変更
- 3択のアップグレード選択肢を表示

**関連**: LevelSystem.level_up シグナル, UpgradePanel

---

### ExpOrb（経験値オーブ）
**定義**: 敵撃破時にドロップする経験値アイテム
**英語**: ExpOrb, Experience Orb
**日本語**: 経験値オーブ
**型**: `ExpOrb` (Area2D)
**プロパティ**:
- `exp_value: int` - 経験値量
- `attract_radius: float` - 吸引半径
- `attract_speed: float` - 吸引速度

**ライフサイクル**: PoolManagerで管理（queue_free禁止）

**関連**: Enemy, LevelSystem, PoolManager.spawn_exp_orb()

---

## 2.4 武器関連

### Weapon（武器データ）
**定義**: 武器の基礎データを保持するResource
**英語**: Weapon
**日本語**: 武器（データ）
**型**: `Weapon` (Resource)
**プロパティ**:
- `weapon_name: String` - 武器名
- `description: String` - 説明文
- `base_damage: int` - 基礎ダメージ
- `attack_interval: float` - 攻撃間隔（秒）
- `attack_type: AttackType` - 攻撃種類（enum）

**関連**: WeaponInstance, resources/weapons/*.tres

---

### WeaponInstance（武器インスタンス）
**定義**: 武器の実体を表すNodeクラス
**英語**: WeaponInstance
**日本語**: 武器インスタンス
**型**: `WeaponInstance` (Node)
**責務**:
- 武器データ（Weapon Resource）の読み込み
- 攻撃タイミング制御
- 攻撃処理の実行
- レベルアップ時のパラメータ強化

**プロパティ**:
- `weapon_data: Weapon` - 武器データ
- `current_level: int` - 武器レベル
- `owner_player: Node` - 所有プレイヤー

**注意**: `get_parent().get_parent()`は使用禁止

**関連**: Weapon, WeaponManager

---

### WeaponManager（武器管理）
**定義**: プレイヤーが所持する武器を管理するNodeクラス
**英語**: WeaponManager
**日本語**: 武器管理
**型**: `WeaponManager` (Node)
**責務**:
- 武器インスタンスの追加・削除
- 武器スロット管理（最大6個）
- 武器レベルアップ処理

**定数**:
- `MAX_WEAPONS = 6`

**関連**: Player, WeaponInstance

---

### AttackType（攻撃種類）
**定義**: 武器の攻撃パターンを表すenum
**英語**: Attack Type
**日本語**: 攻撃種類
**型**: `Weapon.AttackType` (enum)
**値**:
- `STRAIGHT_SHOT`: 直線弾（プレイヤーの移動方向）
- `AREA_BLAST`: 範囲爆発（周囲全方位）
- `HOMING_MISSILE`: 誘導ミサイル（最も近い敵を追尾）

**関連**: Weapon.attack_type

---

### Projectile（弾丸）
**定義**: 武器から発射される攻撃オブジェクト
**英語**: Projectile
**日本語**: 弾丸、発射物
**型**: `Projectile` (Area2D)
**プロパティ**:
- `damage: int` - ダメージ量
- `speed: float` - 移動速度
- `direction: Vector2` - 移動方向
- `lifetime: float` - 生存時間（秒）

**ライフサイクル**: PoolManagerで管理

**関連**: WeaponInstance, PoolManager.spawn_projectile()

---

## 2.5 敵関連

### Enemy（敵）
**定義**: プレイヤーを攻撃する敵キャラクター
**英語**: Enemy
**日本語**: 敵
**型**: `Enemy` (CharacterBody2D)
**責務**:
- AIによる行動制御
- HP管理
- 接触ダメージ処理
- 撃破時の経験値オーブドロップ

**種類**:
- `BasicEnemy`: 基本敵（HP 30, 速度 100, ダメージ 10）
- `StrongEnemy`: 強敵（HP 80, 速度 80, ダメージ 20）

**関連**: AIController, EnemySpawner, PoolManager

---

### AIController（AI制御）
**定義**: 敵の行動パターンを定義するResource
**英語**: AIController
**日本語**: AI制御
**型**: `AIController` (Resource)
**責務**:
- 行動ロジックの定義
- 移動方向の計算

**具体的実装**:
- `AIChasePlayer`: プレイヤーを追跡
- （将来的）`AIZigzag`: ジグザグ移動
- （将来的）`AICircle`: 円周移動

**パターン**: Strategy Pattern

**関連**: Enemy.ai_controller

---

### EnemySpawner（敵スポーナー）
**定義**: 敵を定期的に生成するシステム
**英語**: Enemy Spawner
**日本語**: 敵スポーナー
**型**: `EnemySpawner` (Node)
**責務**:
- 敵のスポーンタイミング制御
- スポーン位置の決定（画面外）
- 難易度曲線による敵種類選択

**パラメータ**:
- `base_spawn_interval: float = 2.0` - 基本スポーン間隔（秒）
- `difficulty_curve: Curve` - 難易度曲線

**関連**: PoolManager, Enemy, DifficultyCurve

---

### DifficultyCurve（難易度曲線）
**定義**: 時間経過による敵の出現頻度・種類を制御するCurve
**英語**: Difficulty Curve
**日本語**: 難易度曲線
**型**: `Curve` (Resource)
**範囲**: `0.0 (開始時) ~ 1.0 (15分時点)`
**用途**:
- スポーン間隔の短縮
- 強敵の出現確率増加

**計算式**: `spawn_interval = base_interval / max(0.05, curve.sample(progress))`

**関連**: EnemySpawner

---

## 2.6 アップグレード関連

### Upgrade（アップグレード）
**定義**: レベルアップ時にプレイヤーが選択できる強化
**英語**: Upgrade
**日本語**: アップグレード、強化
**種類**: `UpgradeType` (enum)

**UpgradeType一覧**:
- `NEW_WEAPON`: 新規武器追加
- `WEAPON_LEVEL_UP`: 既存武器レベルアップ
- `MAX_HP`: 最大HP増加
- `SPEED`: 移動速度増加

**関連**: UpgradeGenerator, UpgradeApplier

---

### UpgradePanel（アップグレードパネル）
**定義**: レベルアップ時に表示される3択UI
**英語**: Upgrade Panel
**日本語**: アップグレードパネル
**型**: `UpgradePanel` (Control)
**責務**:
- 3つの選択肢を表示
- プレイヤーの選択を受け付ける
- 選択結果をUpgradeApplierに送信

**process_mode**: `PROCESS_MODE_ALWAYS`（ポーズ中も動作）

**関連**: UpgradeGenerator, UpgradeApplier

---

### UpgradeGenerator（アップグレード生成）
**定義**: レベルアップ時の3択を生成するロジック
**英語**: Upgrade Generator
**日本語**: アップグレード生成
**型**: `UpgradeGenerator` (Node)
**責務**:
- 現在の状況を分析（武器数、レベル等）
- 適切な選択肢を3つ生成
- レアリティ抽選（70% 通常、30% レア）

**関連**: UpgradePanel, UpgradeType

---

### UpgradeApplier（アップグレード適用）
**定義**: 選択されたアップグレードを実際に適用するロジック
**英語**: Upgrade Applier
**日本語**: アップグレード適用
**型**: `UpgradeApplier` (Node)
**責務**:
- UpgradePanelからの選択を受け取る
- プレイヤー・武器への効果適用
- ゲーム状態を`PLAYING`に戻す

**関連**: UpgradePanel, Player, WeaponManager

---

## 2.7 UI関連

### HUD（ヘッドアップディスプレイ）
**定義**: ゲームプレイ中に常時表示される情報UI
**英語**: HUD, Head-Up Display
**日本語**: HUD、情報表示
**型**: `HUD` (CanvasLayer)
**表示内容**:
- 現在HP / 最大HP
- 現在レベル
- 経験値バー
- 経過時間

**関連**: Player, LevelSystem

---

### GameOverScreen（ゲームオーバー画面）
**定義**: プレイヤー死亡時に表示される画面
**英語**: Game Over Screen
**日本語**: ゲームオーバー画面
**型**: `GameOverScreen` (Control)
**表示内容**:
- 最終統計（撃破数、経過時間等）
- リトライボタン
- タイトルに戻るボタン

**process_mode**: `PROCESS_MODE_ALWAYS`

**関連**: GameManager.game_stats

---

# 3. 技術用語

## 3.1 Godotエンジン用語

### Autoload（オートロード）
**定義**: Godotのシングルトンパターン実装
**英語**: Autoload
**日本語**: オートロード
**用途**: ゲーム全体で共有する状態管理

**本プロジェクトの制限**: 3つまで
- `GameManager`
- `LevelSystem`
- `PoolManager`

**注意**: グローバル状態の肥大化を避けるため最小限に抑える

**関連**: project.godot の [autoload] セクション

---

### Signal（シグナル）
**定義**: Godotのイベント通知機構
**英語**: Signal
**日本語**: シグナル
**用途**: 疎結合なオブジェクト間通信

**使用ガイドライン**:
- **下位→上位**: Signalを使用
- **上位→下位**: 直接メソッド呼び出し
- **同レイヤー**: 極力避ける

**例**:
```gdscript
signal level_up(new_level: int)
```

**関連**: development-guidelines.md Section 2.4

---

### Resource（リソース）
**定義**: データを保持するGodotのクラス
**英語**: Resource
**日本語**: リソース
**特徴**:
- Nodeツリーに依存しない
- ファイルとして保存可能（.tres）
- データ駆動設計に適する

**本プロジェクトでの使用**:
- `Weapon` - 武器データ
- `AIController` - AI行動パターン
- `GameStats` - ゲーム統計

**関連**: resources/ ディレクトリ

---

### Scene（シーン）
**定義**: Godotのノードツリー構造を保存したファイル
**英語**: Scene
**日本語**: シーン
**拡張子**: `.tscn`（テキスト形式必須）

**設計原則**:
- 1シーン = 1責務
- ノード数は50個以下
- 再利用性を重視

**関連**: scenes/ ディレクトリ

---

### Node（ノード）
**定義**: Godotのシーンツリーを構成する基本単位
**英語**: Node
**日本語**: ノード
**種類**:
- `Node2D`: 2D空間のオブジェクト
- `CharacterBody2D`: 物理演算キャラクター
- `Area2D`: 当たり判定領域
- `Control`: UI要素

**関連**: Scene

---

### process_mode（処理モード）
**定義**: ポーズ時のノードの動作を制御する設定
**英語**: Process Mode
**日本語**: 処理モード
**値**:
- `PROCESS_MODE_PAUSABLE`: ポーズ時停止（ゲームオブジェクト）
- `PROCESS_MODE_ALWAYS`: ポーズ時も動作（UI）

**関連**: GameManager.change_state(), UpgradePanel

---

## 3.2 設計パターン用語

### Object Pool Pattern（オブジェクトプール）
**定義**: オブジェクトの生成・破棄コストを削減するパターン
**英語**: Object Pool Pattern
**日本語**: オブジェクトプールパターン
**実装**: `PoolManager` (Autoload)

**プール対象**:
- Enemy（敵）
- Projectile（弾丸）
- ExpOrb（経験値オーブ）

**禁止事項**: `queue_free()`の直接使用

**関連**: PoolManager, ADR-002

---

### Strategy Pattern（戦略パターン）
**定義**: アルゴリズムを動的に切り替えるパターン
**英語**: Strategy Pattern
**日本語**: 戦略パターン
**実装**: `AIController` (Resource)

**具体例**:
- `AIChasePlayer` - 追跡AI
- （将来的）`AIZigzag` - ジグザグAI

**関連**: Enemy.ai_controller

---

### Singleton Pattern（シングルトン）
**定義**: クラスのインスタンスが1つだけ存在することを保証するパターン
**英語**: Singleton Pattern
**日本語**: シングルトンパターン
**Godot実装**: Autoload

**本プロジェクトの例**:
- `GameManager`
- `LevelSystem`
- `PoolManager`

**関連**: Autoload

---

## 3.3 アーキテクチャ用語

### MVP（Model-View-Presenter） ※ここでは最小実用製品と区別
**定義**: UIアーキテクチャパターン
**英語**: MVP (Architecture)
**日本語**: MVPパターン
**注意**: 本プロジェクトでは「Minimum Viable Product」と区別すること

---

### ADR（Architectural Decision Record）
**定義**: アーキテクチャ上の重要な決定を記録する文書
**英語**: ADR, Architectural Decision Record
**日本語**: アーキテクチャ決定記録
**形式**:
- 日付
- 決定内容
- 理由
- 代替案

**本プロジェクトのADR**:
- ADR-001: Autoloadを3つに限定
- ADR-002: シーンパス別プール採用
- ADR-003: WeaponをResource化

**関連**: architecture.md Section 19

---

### Data-Driven Design（データ駆動設計）
**定義**: ロジックとデータを分離し、データで振る舞いを制御する設計
**英語**: Data-Driven Design
**日本語**: データ駆動設計
**実装**: ResourceパターンでWeapon, AIControllerをデータ化

**メリット**:
- コード変更なしでパラメータ調整可能
- .tresファイルでバランス調整

**関連**: Weapon Resource, AIController Resource

---

## 3.4 パフォーマンス用語

### FPS（Frames Per Second）
**定義**: 1秒間に描画されるフレーム数
**英語**: FPS, Frames Per Second
**日本語**: フレームレート
**目標値**:
- ターゲット: 60 FPS
- 最低保証: 30 FPS

**計測**: `Engine.get_frames_per_second()`

**関連**: performance_monitor.gd

---

### Delta Time（デルタタイム）
**定義**: 前フレームからの経過時間（秒）
**英語**: Delta Time
**日本語**: デルタタイム
**型**: `float`
**用途**: フレームレート非依存の処理

**例**:
```gdscript
func _process(delta: float) -> void:
    position += velocity * delta  # デルタタイムで補正
```

**関連**: _process(), _physics_process()

---

### Memory Leak（メモリリーク）
**定義**: 不要なオブジェクトがメモリ上に残り続ける問題
**英語**: Memory Leak
**日本語**: メモリリーク
**原因**:
- Signal接続の解除忘れ
- 循環参照
- オブジェクトの解放忘れ

**対策**:
- `_exit_tree()`でSignal解除
- `WeakRef`使用
- オブジェクトプール使用

**関連**: development-guidelines.md Section 3.3

---

# 4. ドメイン固有用語（ローグライト）

## 4.1 ローグライト用語

### Roguelite / Roguelike（ローグライト / ローグライク）
**定義**: ランダム生成、永久死、ビルド構築を特徴とするゲームジャンル
**英語**: Roguelite / Roguelike
**日本語**: ローグライト / ローグライク
**本プロジェクトの特徴**:
- 1回のプレイは最大15分
- レベルアップで3択のビルド構築
- 死亡時は最初からやり直し

**参考**: Vampire Survivors

---

### Build（ビルド）
**定義**: プレイヤーが選択した武器・アップグレードの組み合わせ
**英語**: Build
**日本語**: ビルド、構成
**例**:
- 「高速移動 + 範囲攻撃」ビルド
- 「低速移動 + 高火力」ビルド

**関連**: Upgrade, Weapon

---

### Run（ラン）
**定義**: ゲーム開始から死亡/クリアまでの1回のプレイセッション
**英語**: Run
**日本語**: ラン、周回
**期間**: 最大15分

**関連**: GameStats

---

### Permadeath（永久死）
**定義**: 死亡時にプレイ中の進行が全てリセットされる仕様
**英語**: Permadeath, Permanent Death
**日本語**: 永久死
**本プロジェクト**: MVP時点では永続的な強化なし（純粋な永久死）

**将来的**: メタ進行（永続強化）追加の可能性

---

## 4.2 ゲームバランス用語

### Scaling（スケーリング）
**定義**: 時間経過やレベルアップによるパラメータの増加
**英語**: Scaling
**日本語**: スケーリング、成長曲線
**例**:
- 武器レベルによるダメージ増加
- 難易度曲線による敵の強化

**関連**: DifficultyCurve, WeaponInstance.current_level

---

### Synergy（シナジー）
**定義**: 複数の要素が組み合わさることで相乗効果を生む仕組み
**英語**: Synergy
**日本語**: シナジー、相乗効果
**例**（将来的）:
- 「移動速度UP + 貫通弾」で高機動射撃
- 「範囲攻撃 + 攻撃速度UP」で殲滅力強化

**注意**: MVP範囲外

---

# 5. 開発プロセス用語

## 5.1 ドキュメント用語

### Permanent Documents（永続的ドキュメント）
**定義**: プロジェクト全体の設計を記述する長期的なドキュメント
**英語**: Permanent Documents
**日本語**: 永続的ドキュメント
**配置場所**: `docs/`
**ファイル**:
- product-requirements.md
- functional-design.md
- architecture.md
- repository-structure.md
- development-guidelines.md
- glossary.md（本ファイル）

**更新タイミング**: 基本設計変更時のみ

**関連**: CLAUDE.md

---

### Steering Documents（ステアリングドキュメント）
**定義**: 特定の開発作業に特化した一時的なドキュメント
**英語**: Steering Documents
**日本語**: ステアリングドキュメント、作業ドキュメント
**配置場所**: `.steering/[YYYYMMDD]-[タイトル]/`
**ファイル**:
- requirements.md - 作業要求
- design.md - 設計内容
- tasklist.md - タスクリスト

**更新タイミング**: 作業開始時作成、完了時保存

**関連**: CLAUDE.md

---

### Ubiquitous Language（ユビキタス言語）
**定義**: プロジェクト全体で統一的に使用される共通言語
**英語**: Ubiquitous Language
**日本語**: ユビキタス言語
**目的**: 開発者、コード、ドキュメント間の用語の一貫性確保

**本ドキュメント**: glossary.md がその実装

**出典**: ドメイン駆動設計（DDD）

---

## 5.2 Git用語

### Feature Branch（機能ブランチ）
**定義**: 新機能開発用のGitブランチ
**英語**: Feature Branch
**日本語**: 機能ブランチ
**命名**: `feature/[機能名]`
**例**: `feature/add-boss-battle`

**関連**: development-guidelines.md Section 6.1

---

### Commit Message（コミットメッセージ）
**定義**: コミットの内容を説明する短文
**英語**: Commit Message
**日本語**: コミットメッセージ
**形式**: `[種類] 簡潔な変更内容`
**種類**:
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `refactor`: リファクタリング
- `perf`: パフォーマンス改善
- `test`: テスト追加
- `chore`: ビルド・設定

**関連**: development-guidelines.md Section 6.2

---

## 5.3 テスト用語

### GUT（Godot Unit Test）
**定義**: Godot向け単体テストフレームワーク
**英語**: GUT, Godot Unit Test
**日本語**: GUT
**用途**: 将来的な自動テスト導入

**関連**: development-guidelines.md Section 5.3

---

### Manual Test（手動テスト）
**定義**: 人間が実際にプレイして行うテスト
**英語**: Manual Test
**日本語**: 手動テスト
**本プロジェクト**: MVP時点ではこれが主

**チェックリスト**: development-guidelines.md Section 5.1

---

# 6. ファイル・ディレクトリ用語

## 6.1 ファイル拡張子

### .gd（GDScript）
**定義**: GDScriptソースコードファイル
**拡張子**: `.gd`
**配置**:
- `autoload/` - Autoloadスクリプト
- `scripts/` - 一般スクリプト
- `resources/` - Resourceクラス定義

---

### .tscn（Text Scene）
**定義**: Godotシーンファイル（テキスト形式）
**拡張子**: `.tscn`
**配置**: `scenes/`
**注意**: バイナリ形式（.scn）は使用禁止（Git差分管理のため）

---

### .tres（Text Resource）
**定義**: Godot Resourceファイル（テキスト形式）
**拡張子**: `.tres`
**配置**: `resources/` のサブディレクトリ
**例**: `resources/weapons/straight_shot.tres`

---

## 6.2 ディレクトリ用語

### autoload/
**定義**: Autoloadスクリプト配置ディレクトリ
**内容**: GameManager, LevelSystem, PoolManager（3つのみ）

---

### resources/
**定義**: Resourceクラス定義と.tresデータ配置ディレクトリ
**内容**: Weapon, AIController, GameStats等

---

### scenes/
**定義**: .tscnファイル配置ディレクトリ
**内容**: ゲームオブジェクトのシーン構造

---

### scripts/
**定義**: GDScriptファイル配置ディレクトリ
**内容**: scenes/と対称的な構造

---

### assets/
**定義**: ゲームアセット配置ディレクトリ
**内容**: sprites/, sounds/, fonts/

---

### docs/
**定義**: 永続的ドキュメント配置ディレクトリ
**内容**: 設計書、仕様書、ガイドライン

---

### .steering/
**定義**: 作業ドキュメント配置ディレクトリ
**内容**: 作業ごとのrequirements/design/tasklist

---

# 7. 略語・記号

## 7.1 一般略語

| 略語 | 正式名称 | 日本語 |
|------|---------|--------|
| AI | Artificial Intelligence | 人工知能 |
| API | Application Programming Interface | アプリケーションプログラミングインターフェース |
| DDD | Domain-Driven Design | ドメイン駆動設計 |
| EXP | Experience | 経験値 |
| FPS | Frames Per Second | フレームレート |
| HP | Hit Points | ヒットポイント |
| HUD | Head-Up Display | ヘッドアップディスプレイ |
| MVP | Minimum Viable Product | 最小実用製品 |
| UI | User Interface | ユーザーインターフェース |

---

## 7.2 プロジェクト固有略語

| 略語 | 正式名称 | 説明 |
|------|---------|------|
| GM | GameManager | ゲーム状態管理Autoload |
| LS | LevelSystem | 経験値・レベル管理Autoload |
| PM | PoolManager | オブジェクトプール管理Autoload |
| WM | WeaponManager | 武器管理Node |
| WI | WeaponInstance | 武器インスタンスNode |

**注意**: コード内では略語ではなく正式名称を使用すること

---

# 8. 命名規則サマリー

## 8.1 GDScript命名規則

| 対象 | 規則 | 例 |
|------|------|-----|
| クラス名 | PascalCase | `Player`, `WeaponInstance` |
| ファイル名 | snake_case | `player.gd`, `weapon_instance.gd` |
| 関数名 | snake_case | `add_exp()`, `spawn_enemy()` |
| 変数名 | snake_case | `current_hp`, `max_weapons` |
| 定数名 | SCREAMING_SNAKE_CASE | `MAX_HP`, `BASE_SPEED` |
| シグナル名 | snake_case | `level_up`, `hp_changed` |
| プライベート変数 | `_` + snake_case | `_internal_state` |
| enum値 | SCREAMING_SNAKE_CASE | `STRAIGHT_SHOT`, `GAME_OVER` |

---

## 8.2 ファイル・ディレクトリ命名規則

| 対象 | 規則 | 例 |
|------|------|-----|
| ディレクトリ | snake_case | `autoload/`, `enemy_spawner/` |
| シーンファイル | snake_case.tscn | `player.tscn`, `game_over_screen.tscn` |
| スクリプトファイル | snake_case.gd | `player.gd`, `weapon_instance.gd` |
| Resourceファイル | snake_case.tres | `straight_shot.tres` |

---

# 9. 用語の使い分け

## 9.1 紛らわしい用語

### Game State vs GameStats
- **Game State**: ゲームの実行状態（PLAYING/PAUSED等）
- **GameStats**: ゲームの統計情報（撃破数、ダメージ等）

### MVP (Product) vs MVP (Pattern)
- **MVP（Product）**: Minimum Viable Product（最小実用製品）
- **MVP（Pattern）**: Model-View-Presenter（アーキテクチャパターン）
- **本プロジェクト**: 前者のみ使用

### Level (Player) vs Level (Weapon)
- **Player Level**: プレイヤーの成長段階（LevelSystemが管理）
- **Weapon Level**: 個別武器の強化レベル（WeaponInstanceが管理）

### Resource (Godot) vs Resource (Asset)
- **Resource（Godot）**: Godotのクラス（Weapon, GameStats等）
- **Resource（Asset）**: ゲームアセット全般（画像、音声等）
- **本プロジェクト**: 前者は「Resource」、後者は「Asset」と呼び分ける

---

# 10. 変更履歴

## 2026-02-26: 初版作成

### 定義済み用語カテゴリ
1. **ゲームシステム用語** - Game State, Player, Experience, Weapon等
2. **技術用語** - Autoload, Signal, Resource, Object Pool等
3. **ドメイン固有用語** - Roguelite, Build, Run, Permadeath等
4. **開発プロセス用語** - Permanent Documents, Steering Documents等
5. **ファイル・ディレクトリ用語** - .gd, .tscn, .tres, autoload/等
6. **略語・記号** - AI, FPS, HP, GM, LS, PM等
7. **命名規則** - snake_case, PascalCase, SCREAMING_SNAKE_CASE
8. **用語の使い分け** - 紛らわしい用語の明確化

### 整合性確認
- ✅ functional-design.md - クラス名、システム名
- ✅ architecture.md - 技術用語、ADR
- ✅ repository-structure.md - ディレクトリ名、ファイル命名規則
- ✅ development-guidelines.md - コーディング規約、命名規則

---

**ユビキタス言語定義完了**: 全プロジェクト用語を統一的に定義済み
