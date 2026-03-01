# architecture.md
技術仕様書

---

# 1. テクノロジースタック

## ゲームエンジン
- **Godot Engine 4.3 (stable)**
  - オープンソース、軽量、2D特化の優れたパフォーマンス
  - GDScriptによる高速プロトタイピング
  - シーンシステムによる柔軟な構造設計

## プログラミング言語
- **GDScript**
  - Godot専用の動的型付け言語
  - Pythonライクな文法で学習コスト低
  - Godotエンジンとの深い統合

## バージョン管理
- **Git**
  - シーンファイルは`.tscn`（テキスト形式）で管理
  - `.gitignore`でGodot固有の一時ファイルを除外

## 開発環境
- **VSCode**
  - Claude Code拡張機能
  - Godot Tools拡張機能（推奨）
- **Devcontainer (Ubuntu base)**
  - 再現可能な開発環境
  - Godot 4.3 CLIインストール済み

---

# 2. 開発ツールと手法

## IDEとエディタ
### VSCode (推奨)
- **拡張機能**:
  - `claude-code`: AI支援開発
  - `godot-tools`: GDScriptシンタックスハイライト・補完
  - `EditorConfig`: コーディング規約統一

### Godotエディタ
- シーン編集、ビジュアル調整に使用
- スクリプトはVSCodeで編集（分離推奨）

## デバッグツール
- **Godot内蔵デバッガ**
  - ブレークポイント、変数監視
  - リモートデバッグ対応
- **print()デバッグ**
  - 軽量で高速、MVP開発に適する
- **push_warning() / push_error()**
  - ログレベル分け、本番環境でフィルタ可能

## ビルドツール
```bash
# ヘッドレスモードでのエクスポート
godot --headless --export-release "Linux/X11" ./build/game.x86_64

# テスト実行（将来的にGUT等のフレームワーク導入可能）
godot --headless -s addons/gut/gut_cmdln.gd
```

---

# 3. 技術的制約と要件

## ハードウェア要件（最小）
- **CPU**: 2コア以上
- **RAM**: 2GB以上
- **GPU**: OpenGL 3.3対応
- **Storage**: 100MB以上

## ソフトウェア要件
- **OS**: Linux (Ubuntu推奨), Windows, macOS
- **Godot**: 4.3以上
- **Git**: 2.x以上

## ブラウザ対応（将来的）
- HTML5エクスポート可能
- WebGL 2.0対応ブラウザ（Chrome, Firefox, Edge）

---

# 4. パフォーマンス要件

## フレームレート目標
- **ターゲット**: 60 FPS
- **最低保証**: 30 FPS（低スペック環境）

## レスポンス要件
- **入力遅延**: 16ms以内（1フレーム以内）
- **シーン読み込み**: 1秒以内
- **起動時間**: 5秒以内

## メモリ使用量
- **最大**: 512MB RAM（敵・弾丸最大数時）
- **通常**: 256MB RAM（平均プレイ時）

## オブジェクト数上限
- **敵**: 200体（同時アクティブ）
- **弾丸**: 500発（同時アクティブ）
- **経験値オーブ**: 200個（同時アクティブ）

---

# 5. アーキテクチャパターン

## 全体設計方針
- **Godotのシーンツリー中心**
- **Autoloadパターン** (Singleton) - 状態管理に限定
- **Resourceパターン** - データとロジックの分離
- **Strategyパターン** - AI行動の拡張性確保
- **Object Poolパターン** - メモリ効率化

## レイヤー構造

```
┌─────────────────────────────────────┐
│   Presentation Layer (UI)           │  ← CanvasLayer、Control
├─────────────────────────────────────┤
│   Game Logic Layer                  │  ← Player, Enemy, Weapon
├─────────────────────────────────────┤
│   System Layer (Autoload)           │  ← GameManager, LevelSystem
├─────────────────────────────────────┤
│   Resource Layer                    │  ← Weapon, AIController (Data)
└─────────────────────────────────────┘
```

### レイヤー間の通信
- **上位→下位**: 直接メソッド呼び出し
- **下位→上位**: Signalによるイベント通知
- **同レイヤー**: 極力避ける（疎結合維持）

---

# 6. データ管理戦略

## 状態管理
### GameManager (Autoload)
- ゲーム全体の状態（TITLE/PLAYING/PAUSED/UPGRADE/GAME_OVER）
- ゲーム統計（GameStats Resource）
- ポーズ制御の唯一の権限者

### LevelSystem (Autoload)
- 経験値・レベルの唯一の管理者
- レベルアップ通知（Signal）

### PoolManager (Autoload)
- オブジェクトの生成・破棄管理
- シーンパス別プール
- 親ノード委譲（world_node）

## データ永続化（将来的）
現在のMVPでは実装しないが、拡張時の設計指針:

### セーブデータ構造
```gdscript
class_name SaveData extends Resource

var player_progress: Dictionary = {}  # 永続強化情報
var unlocked_weapons: Array[String] = []
var high_score: int = 0
var total_playtime: float = 0.0
```

### セーブ/ロード方式
- `ResourceSaver.save()` / `ResourceLoader.load()`
- パス: `user://save_data.tres`
- 暗号化: ConfigFile + Base64（簡易）

---

# 7. ネットワークアーキテクチャ（将来的）

## MVP範囲外
現在はシングルプレイヤーのみ。

## 将来的な拡張可能性
- **リーダーボード**: HTTPRequest経由でスコア送信
- **クラウドセーブ**: REST API経由でセーブデータ同期
- **マルチプレイ**: Godotの`MultiplayerAPI`使用（P2P or 専用サーバー）

---

# 8. セキュリティ考慮事項

## クライアントサイド
- **入力検証**: プレイヤー入力の範囲チェック（速度制限等）
- **チート対策**: クリティカルな値はサーバー側で検証（将来的）
- **リソース保護**: 画像・音声の難読化（商用リリース時）

## データ整合性
- **セーブデータ**: チェックサムによる改ざん検出（将来的）
- **リプレイ検証**: 入力シーケンスの記録（デバッグ用）

---

# 9. エラーハンドリング戦略

## エラー分類

### 致命的エラー（Critical）
- プール上限超過（nullチェック必須）
- Autoload未初期化
- 必須Resourceのロード失敗

**対応**: `push_error()` + ゲーム終了 or デフォルト値フォールバック

### 警告（Warning）
- 武器6個所持時の追加試行
- 経験値オーブ上限到達

**対応**: `push_warning()` + 処理スキップ

### 情報（Info）
- レベルアップ
- 敵撃破数

**対応**: `print()` デバッグ出力

## エラーログ
```gdscript
# autoload/logger.gd (将来的)
extends Node

enum LogLevel { DEBUG, INFO, WARNING, ERROR, CRITICAL }

func log(level: LogLevel, message: String, context: Dictionary = {}) -> void:
    var timestamp = Time.get_datetime_string_from_system()
    var formatted = "[%s][%s] %s" % [timestamp, LogLevel.keys()[level], message]

    match level:
        LogLevel.ERROR, LogLevel.CRITICAL:
            push_error(formatted)
        LogLevel.WARNING:
            push_warning(formatted)
        _:
            print(formatted)
```

---

# 10. テスト戦略

## 単体テスト（MVP範囲外、将来的に導入）
### GUT (Godot Unit Test)
```gdscript
extends GutTest

func test_level_system_exp_calculation():
    var level_system = LevelSystem.new()
    level_system.base_exp = 10
    level_system.exp_growth_rate = 1.18

    var exp_lv2 = level_system._calculate_next_level_exp(2)
    assert_eq(exp_lv2, 12, "Lv2の必要経験値は12")
```

## 統合テスト
### 手動プレイテスト
- 15分間の完走テスト
- レベルアップ3択の動作確認
- 敵数上限到達時の挙動確認

## パフォーマンステスト
```gdscript
# scripts/debug/performance_monitor.gd
extends Node

func _process(delta: float) -> void:
    var fps = Engine.get_frames_per_second()
    var memory = OS.get_static_memory_usage() / 1024.0 / 1024.0  # MB

    if fps < 30:
        push_warning("FPS低下: %d" % fps)
    if memory > 512:
        push_warning("メモリ使用量超過: %.1f MB" % memory)
```

---

# 11. デプロイメント戦略

## ビルド手順
```bash
# Linux向けエクスポート
godot --headless --export-release "Linux/X11" ./build/game_linux.x86_64

# Windows向けエクスポート
godot --headless --export-release "Windows Desktop" ./build/game_windows.exe

# HTML5向けエクスポート（将来的）
godot --headless --export-release "HTML5" ./build/index.html
```

## リリースフロー（将来的）
1. **開発ブランチ**: `dev`
2. **リリースブランチ**: `release/vX.Y.Z`
3. **タグ付け**: `git tag v1.0.0`
4. **自動ビルド**: GitHub Actions（将来的）
5. **配布**: itch.io / Steam（商用時）

---

# 12. 監視とロギング

## デバッグモード
```gdscript
# autoload/game_manager.gd
const DEBUG_MODE = OS.is_debug_build()

func _ready() -> void:
    if DEBUG_MODE:
        print("=== DEBUG MODE ===")
        print("Godot Version: ", Engine.get_version_info())
        print("OS: ", OS.get_name())
```

## パフォーマンスメトリクス
- FPS（毎フレーム計測）
- メモリ使用量（定期的に計測）
- アクティブオブジェクト数（PoolManager経由）

---

# 13. 技術的負債の管理

## 既知の制約・妥協点

### MVP時点での意図的な簡略化
1. **テストコードなし**: 手動テストのみ
2. **セーブ機能なし**: リスタートのみ
3. **サウンドなし**: ビジュアルのみ
4. **エフェクト最小限**: パーティクル未使用

### 将来的なリファクタリング候補
- `UpgradeGenerator`のロジック複雑化 → Builder パターン導入
- `Enemy`の種類増加 → Factory パターン導入
- `WeaponInstance`の攻撃種類増加 → Command パターン導入

---

# 14. 依存関係管理

## 外部依存
- **なし**（Godot標準機能のみ使用）

## 内部依存（Autoload間）
```
GameManager
  ↓ (start_game時に呼ぶ)
LevelSystem.reset()
PoolManager.clear_all_active()
```

## 循環依存の禁止
- Autoload同士の相互依存は避ける
- 必要な場合はSignalで疎結合化

---

# 15. 拡張性の技術的担保

## プラグインアーキテクチャ（将来的）
```
addons/
├── custom_weapons/  # 武器追加プラグイン
├── boss_battles/    # ボス戦プラグイン
└── persistent_upgrades/  # 永続強化プラグイン
```

## Mod対応（将来的）
- `.pck` ファイルによるコンテンツ追加
- `res://mods/` ディレクトリからの動的ロード

---

# 16. ドキュメント管理

## コード内ドキュメント
```gdscript
## プレイヤークラス
##
## 責務:
## - 移動入力の処理
## - HP管理
## - 経験値オーブの回収（LevelSystemへ委譲）
##
## 依存:
## - WeaponManager
## - LevelSystem (Autoload)
class_name Player extends CharacterBody2D
```

## API仕様書（自動生成、将来的）
- GDScriptの`##`コメントからMarkdown生成
- `gdscript-docs-maker`等のツール使用

---

# 17. 技術選択の理由

## Godot Engine採用理由
1. **オープンソース**: コスト0、商用利用自由
2. **2D最適化**: 軽量、高速
3. **学習コスト低**: GDScript、豊富なドキュメント
4. **シーンシステム**: 再利用性、Git管理しやすい

## GDScript採用理由
1. **Godot統合**: エディタとの深い連携
2. **開発速度**: 動的型付け、短いコード
3. **デバッグ容易**: ホットリロード対応

## Autoloadパターン採用理由
1. **状態管理の一元化**: GameManager, LevelSystem
2. **グローバルアクセス**: どこからでも参照可能
3. **ライフサイクル管理**: シーン遷移を超えて存続

---

# 18. 技術的リスクと対策

## リスク1: パフォーマンス低下
**対策**:
- オブジェクトプール実装済み
- 早期負荷テスト（敵200体、弾500発同時）

## リスク2: GDScriptの型安全性不足
**対策**:
- 型アノテーション活用（`var x: int = 0`）
- クラス分割で責務明確化

## リスク3: Godot 4.xの安定性
**対策**:
- 4.3 stable版使用（LTS相当）
- 重要機能はシンプルに保つ

---

# 19. 技術的決定記録（ADR形式）

## ADR-001: Autoloadを3つに限定
**日付**: 2026-02-26
**状態**: 承認済み
**決定**: GameManager, LevelSystem, PoolManagerのみAutoload
**理由**: グローバル状態の肥大化防止、依存関係の明確化
**代替案**: 全てAutoload → 却下（保守性低下）

## ADR-002: シーンパス別プール採用
**日付**: 2026-02-26
**状態**: 承認済み
**決定**: `Dictionary<String, Array[Node]>` で敵種類別プール
**理由**: 型混在によるバグ防止、動的な型追加対応
**代替案**: 単一プール → 却下（basic/strong混在問題）

## ADR-003: WeaponをResource化
**日付**: 2026-02-26
**状態**: 承認済み
**決定**: データ（Weapon Resource）と実体（WeaponInstance Node）分離
**理由**: データ駆動設計、パッシブ武器対応
**代替案**: Node継承のみ → 却下（拡張性不足）

## ADR-004: テクスチャはGDScriptで動的ロード
**日付**: 2026-02-28
**状態**: 承認済み
**決定**: 画像テクスチャは`.tscn`の`ext_resource`ではなく、GDScriptの`load()`で動的にロードする
**理由**: Godotの`.import`ファイル生成タイミングに依存せず、環境差異（Devcontainer/Windows）でも確実にロード可能。`load()`失敗時は`Image.load()` + `ImageTexture.create_from_image()`でフォールバックする
**パターン**:
```gdscript
var tex = load("res://assets/path/to/image.png")
if tex == null:
    var image = Image.new()
    var error = image.load(ProjectSettings.globalize_path("res://assets/path/to/image.png"))
    if error != OK:
        push_error("Failed to load texture")
        return
    tex = ImageTexture.create_from_image(image)
```
**代替案**: `.tscn`の`ext_resource`で参照 → 却下（`.import`未生成時にロード失敗）

---

# 20. 技術的参考資料

## 公式ドキュメント
- [Godot 4.3 Documentation](https://docs.godotengine.org/en/4.3/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

## 参考アーキテクチャ
- Vampire Survivors（ローグライト参考）
- Hades（ビルド構築参考）

## コミュニティリソース
- [Godot Reddit](https://www.reddit.com/r/godot/)
- [Godot Discord](https://discord.gg/godotengine)

---

**技術仕様確定**: MVP開発に必要な技術要件を全て定義済み
