# Godot 2D Roguelike Action Game - Project Context

## プロジェクト概要
- **エンジン**: Godot Engine 4.3 stable
- **言語**: GDScript
- **ジャンル**: 2D Roguelike Action Game (Vampire Survivors風)
- **開発フェーズ**: MVP初期実装中
- **ドキュメント駆動**: 詳細な設計ドキュメント完備

## 自動実装モード

### 実装方針
1. **設計ドキュメント準拠**: `.steering/20260226-initial-implementation/design.md` に厳密に従う
2. **段階的実装**: tasklist.mdのフェーズ順に実装
3. **品質優先**: 型アノテーション、nullチェック、エラーハンドリング徹底
4. **自動進行**: ユーザー承認なしで次のタスクへ進む

### 必須ドキュメント参照順
1. `.steering/20260226-initial-implementation/design.md` - 詳細設計
2. `docs/functional-design.md` - 機能仕様
3. `docs/glossary.md` - 用語定義
4. `docs/development-guidelines.md` - コーディング規約

### 実装時の絶対ルール

#### 1. 型アノテーション（必須）
```gdscript
# ✅ 正しい
var current_hp: int = 100
func add_exp(amount: int) -> bool:

# ❌ 間違い
var current_hp = 100
func add_exp(amount):
```

#### 2. nullチェック（必須）
```gdscript
# ✅ 正しい
if owner_player == null:
    push_error("owner_player is null")
    return

# ❌ 間違い
var pos = owner_player.global_position  # nullチェックなし
```

#### 3. クラスドキュメント（必須）
```gdscript
# ✅ 正しい
## GameManagerクラス
##
## 責務: ゲーム状態管理、ポーズ制御
class_name GameManager extends Node

# ❌ 間違い
class_name GameManager extends Node  # ドキュメントなし
```

#### 4. 設計制約
- ❌ GameManagerをシーンに配置（純粋Autoloadのみ）
- ❌ Playerが経験値を保持（LevelSystemのみ）
- ❌ get_parent().get_parent()（直接参照を渡す）
- ❌ queue_free()直接使用（PoolManager経由必須）
- ❌ Weaponをノードで実装（Resource + WeaponInstance）

### 実装フロー

#### ステップ1: タスク選択
1. `tasklist.md` から次の未完了タスクを確認
2. 依存関係チェック（前提タスクが完了済みか）
3. タスク開始宣言

#### ステップ2: 実装
1. `design.md` から該当コンポーネントの設計を読む
2. 必要なディレクトリを作成
3. コードを実装
   - 型アノテーション必須
   - nullチェック徹底
   - クラスドキュメント記載
   - エラーログ実装

#### ステップ3: 検証
1. 設計との整合性チェック
2. コーディング規約準拠確認
3. エラーがないことを確認

#### ステップ4: 記録
1. `tasklist.md` のチェックボックスを更新
2. 完了したタスクを報告
3. **次のタスクへ自動進行**

### 自動進行の停止条件

以下の場合のみユーザーに確認を求める：
1. **致命的エラー発生**: 設計矛盾、ファイル破損等
2. **フェーズ完了**: フェーズ1-10の各完了時
3. **設計の曖昧性**: design.mdに記載がない内容
4. **依存関係の不足**: 前提タスクが未完了

それ以外は**自動的に次のタスクへ進む**。

### 進捗報告形式

各タスク完了時に簡潔に報告：
```
✅ [1.1.1] autoload/game_manager.gd作成完了
- GameState enum定義
- change_state()実装（ポーズ制御含む）
- 型アノテーション、nullチェック済み
次: [1.1.2] start_game(), end_game()実装
```

### 現在の状態
- **完了タスク**: 0/90
- **現在フェーズ**: フェーズ1（Autoload実装）
- **次のタスク**: [1.1.1] autoload/game_manager.gd作成

## エージェント使用方針

### game-developer
- 新規コンポーネント実装時に使用
- 自動的に設計ドキュメントを参照して実装
- tasklist.md自動更新

### code-reviewer
- フェーズ完了時に自動レビュー
- 品質問題があれば修正後に次フェーズへ

## プロジェクト構造

```
05_poc-godot/
├── autoload/          # 3つのAutoloadのみ
├── resources/         # Resource定義と.tresデータ
├── scenes/           # .tscnファイル（テキスト形式）
├── scripts/          # GDScriptファイル
├── assets/           # 仮アセット
├── docs/             # 永続的ドキュメント（完成済み）
└── .steering/        # 作業ドキュメント（完成済み）
```

## 重要な参照ドキュメント

- 📋 [requirements.md](.steering/20260226-initial-implementation/requirements.md) - MVP範囲
- 🎨 [design.md](.steering/20260226-initial-implementation/design.md) - 詳細設計
- ✅ [tasklist.md](.steering/20260226-initial-implementation/tasklist.md) - タスクリスト
- 📖 [functional-design.md](docs/functional-design.md) - 機能仕様
- 📚 [glossary.md](docs/glossary.md) - 用語定義
- 📝 [development-guidelines.md](docs/development-guidelines.md) - 開発ガイドライン

---

**自動実装モード: 有効**
設計に従って自動的に実装を進めます。フェーズ完了時のみ報告します。
