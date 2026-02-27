# requirements.md
初期実装の要求内容

---

## 作業概要

**作業名**: MVP初期実装
**作業期間**: 2026-02-26 〜
**目的**: 2D Roguelike Action GameのMVP機能を実装し、プレイ可能な状態にする

---

## 実装範囲

### 含まれる機能（MVP範囲内）

1. **Autoloadシステム**
   - GameManager（ゲーム状態管理）
   - LevelSystem（経験値・レベル管理）
   - PoolManager（オブジェクトプール管理）

2. **プレイヤーシステム**
   - Player（移動、HP管理）
   - WeaponManager（武器スロット管理）
   - WeaponInstance（武器の実体）

3. **武器システム**
   - Weapon Resource（武器データ）
   - 3種類の武器実装:
     - 直線ショット
     - 範囲爆発
     - ホーミングミサイル
   - Projectile（弾丸）

4. **敵システム**
   - Enemy基底クラス
   - BasicEnemy（基本敵）
   - StrongEnemy（強敵）
   - AIController Resource（AI基底）
   - AIChasePlayer（追跡AI）
   - EnemySpawner（敵生成）

5. **レベルアップシステム**
   - UpgradeGenerator（3択生成）
   - UpgradeApplier（効果適用）
   - UpgradePanel（UI）

6. **アイテムシステム**
   - ExpOrb（経験値オーブ）

7. **UIシステム**
   - HUD（HP、レベル、経験値バー、経過時間）
   - UpgradePanel（レベルアップ3択）
   - GameOverScreen（ゲームオーバー）
   - TitleScreen（タイトル画面）

8. **シーン構造**
   - main.tscn（エントリーポイント）
   - title.tscn（タイトル）
   - game.tscn（メインゲーム）

9. **Resourceデータ**
   - GameStats Resource
   - 3種類の武器データ（.tres）
   - AIChasePlayer Resource

### 含まれない機能（MVP範囲外）

- サウンド・BGM
- パーティクルエフェクト
- セーブ/ロード機能
- 永続的な強化（メタ進行）
- ボス戦
- 複数ステージ
- 自動テスト（GUT）

---

## 技術要件

### 動作環境
- Godot Engine 4.3 stable
- GDScript
- 解像度: 1920x1080（基準）

### パフォーマンス目標
- ターゲットFPS: 60
- 最低保証FPS: 30
- メモリ使用量: 平均256MB、最大512MB
- 同時オブジェクト数:
  - 敵: 最大200体
  - 弾丸: 最大500発
  - 経験値オーブ: 最大200個

### 品質要件
- 型アノテーション必須
- nullチェック徹底
- エラーハンドリング実装
- コード行数: 1ファイル200行以下推奨
- シーンノード数: 50個以下推奨

---

## 成功基準

### 機能面
- [ ] プレイヤーが4方向移動できる
- [ ] 武器が自動攻撃する
- [ ] 敵がスポーンしてプレイヤーを追跡する
- [ ] 敵を倒すと経験値オーブがドロップする
- [ ] 経験値オーブを回収するとレベルアップする
- [ ] レベルアップ時に3択のアップグレードが表示される
- [ ] アップグレードを選択すると効果が適用される
- [ ] HPが0になるとゲームオーバー画面が表示される
- [ ] ゲームオーバー画面からリトライできる
- [ ] 15分経過で自動的にゲームオーバーになる

### パフォーマンス面
- [ ] 敵100体同時でFPS 30以上を維持
- [ ] 弾丸300発同時でFPS 30以上を維持
- [ ] 15分プレイでメモリ512MB以下

### コード品質面
- [ ] 全てのpublic関数に型アノテーションがある
- [ ] nullチェックが適切に実装されている
- [ ] push_error/push_warningでエラーログが出力される
- [ ] 全Autoloadがproject.godotに登録されている
- [ ] 全シーンファイルが.tscn形式（テキスト形式）である

---

## 制約事項

### 技術的制約
- Godot 4.3の機能のみ使用（外部プラグイン不可）
- GDScriptのみ使用（C#, C++不可）
- Autoloadは3つまで（GameManager, LevelSystem, PoolManager）
- queue_free()の直接使用禁止（PoolManager経由必須）

### 設計制約
- GameManagerは純粋Autoload（シーンに配置しない）
- Playerは経験値を保持しない（LevelSystemのみ）
- WeaponはノードではなくResource
- 敵AIはStrategy Pattern（AIController Resource）
- シーンパス別オブジェクトプール（型混在防止）

### スコープ制約
- MVP範囲に集中（機能拡張は後回し）
- アセット（画像・音声）は仮データで可
- UI/UXは最小限（見た目より動作優先）

---

## 参考ドキュメント

- [product-requirements.md](../../docs/product-requirements.md) - プロダクト要求定義
- [functional-design.md](../../docs/functional-design.md) - 機能設計
- [architecture.md](../../docs/architecture.md) - 技術仕様
- [repository-structure.md](../../docs/repository-structure.md) - リポジトリ構造
- [development-guidelines.md](../../docs/development-guidelines.md) - 開発ガイドライン
- [glossary.md](../../docs/glossary.md) - ユビキタス言語定義

---

## リスク

### 技術的リスク
1. **オブジェクトプールの複雑性**
   - リスク: シーンパス別プールの実装が複雑
   - 対策: functional-design.mdのコード例に忠実に従う

2. **パフォーマンス目標未達**
   - リスク: 敵200体でFPS低下
   - 対策: 早期に負荷テスト実施、最適化の余地を残す

3. **Autoload設計の理解不足**
   - リスク: GameManagerをシーンに配置してしまう
   - 対策: functional-design.mdのフィードバック内容を厳守

### スコープリスク
1. **機能追加の誘惑**
   - リスク: MVP範囲外の機能を実装してしまう
   - 対策: このrequirements.mdを常に参照

---

## 次のステップ

1. **design.mdの作成**: 実装の詳細設計
2. **tasklist.mdの作成**: 具体的な実装タスクリスト
3. **実装開始**: タスクリストに従って順次実装

---

**要求定義完了**: MVP初期実装の範囲と制約を明確化
