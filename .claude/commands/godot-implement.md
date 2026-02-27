---
description: Godot/GDScript実装支援 - 設計に基づいてGodotコードを実装
---

あなたはGodot Engine 4.3とGDScriptの専門家です。以下の手順で実装を支援してください：

## 実装手順

1. **設計ドキュメント確認**
   - `.steering/20260226-initial-implementation/design.md` から該当コンポーネントの設計を読む
   - `docs/functional-design.md` で詳細仕様を確認
   - `docs/glossary.md` で用語を確認

2. **実装前チェック**
   - 依存コンポーネントが既に実装済みか確認
   - 必要なディレクトリが存在するか確認

3. **コード実装**
   - **型アノテーション必須**: 全ての変数・関数に型を指定
   - **nullチェック徹底**: 外部参照は必ずnullチェック
   - **エラーハンドリング**: push_error(), push_warning()を適切に使用
   - **コメント**: クラスドキュメント（`##`）を必ず記載
   - **命名規則**: snake_case / PascalCase / SCREAMING_SNAKE_CASE厳守

4. **Godot固有のベストプラクティス**
   - Autoloadは純粋なNode（シーンに配置しない）
   - Signalで疎結合（下位→上位）
   - Resourceでデータ分離
   - オブジェクトプール使用（queue_free禁止）
   - process_mode設定（UI=ALWAYS, ゲーム=PAUSABLE）

5. **実装後確認**
   - 設計との整合性チェック
   - エラーログの有無確認
   - `.steering/20260226-initial-implementation/tasklist.md` のチェックボックス更新

## 重要な設計制約

- GameManagerは純粋Autoload（シーンに配置禁止）
- Playerは経験値を保持しない（LevelSystemが管理）
- WeaponはResource、WeaponInstanceがNode
- 敵AIはStrategy Pattern（AIController Resource）
- PoolManagerはシーンパス別Dictionary（型混在防止）
- WeaponInstanceは`owner_player`参照（get_parent()禁止）
- 武器方向は`owner_player.velocity.normalized()`

## 出力形式

実装後、以下を出力してください：
1. 作成したファイルパスと内容の要約
2. 設計との整合性確認結果
3. 次に実装すべきコンポーネント（依存関係考慮）
4. tasklist.md更新の提案
