# アセット準備ワークフロー

## 概要
Claude Codeを活用してゲームアセット（PNG等）を効率的に準備する手順。

## フェーズ1: 仕様策定（Claude Code）

### 1.1 アセット仕様書の作成
```bash
# Claude Codeへの依頼例
「docs/asset-specifications.md を作成してください。
以下の情報を含めてください:
- 必要なアセット一覧
- 各アセットのサイズ・フォーマット
- アニメーションフレーム数
- カラーパレット
- AI画像生成用プロンプト例」
```

### 1.2 ディレクトリ構造の作成
```bash
# Claude Codeが実行
mkdir -p assets/{characters,enemies,weapons,ui,effects}
```

## フェーズ2: アセット取得（外部ツール）

### 方法A: AI画像生成
1. Claude Codeが生成したプロンプトをコピー
2. DALL-E/Midjourney/Stable Diffusionで生成
3. `assets/` 配下に保存

### 方法B: 手動作成
1. Aseprite/Piskelで作成
2. 仕様書の規定に従う
3. `assets/` 配下に保存

### 方法C: オープンソースアセット
1. OpenGameArt/Kenney/itch.ioからダウンロード
2. ライセンス確認
3. `assets/` 配下に配置

## フェーズ3: 検証（Claude Code）

### 3.1 アセット存在チェック
```bash
# Claude Codeにスクリプト作成を依頼
「assets/ディレクトリを確認して不足ファイルを
リストアップするスクリプトを作成してください」
```

### 3.2 Godotインポート確認
```bash
godot --headless --path . --quit-after 3
# .godot/imported/ にインポート結果が生成される
```

## フェーズ4: 統合（Claude Code）

### 4.1 シーン・スクリプト生成
```bash
# Claude Codeへの依頼例
「配置したアセットを使用して、
AnimatedSprite2Dベースのプレイヤーシーンを
作成してください。assets/characters/player/ の
画像を使用してください。」
```

### 4.2 動作確認
```bash
godot --path . scenes/characters/player.tscn
```

## ベストプラクティス

### 開発初期
- プレースホルダー（ColorRect等）で開発開始
- アセット仕様書は早めに確定
- 外部ツールでの生成は後回しでOK

### 本格開発
- アセット仕様書に基づいて段階的に実アセット導入
- Claude Codeで検証スクリプトを活用
- バージョン管理はGit LFSを検討

### リリース前
- 全アセットのライセンス確認
- 未使用アセットの削除
- アセットサイズの最適化

## トラブルシューティング

### Q: Claude Codeで画像生成できないのか？
A: Claude Codeは画像生成機能を持ちません。
   外部AI画像生成サービスを併用してください。

### Q: プレースホルダーで開発を進めたい
A: 推奨します。ColorRectやPolygon2Dを使用し、
   後からアセット差し替えを行う設計にしてください。

### Q: どの画像生成ツールが最適？
A:
- プログラマー: AI生成（DALL-E/Stable Diffusion）
- アーティスト: Aseprite/Piskel
- 予算限定: オープンソースアセット + 部分的に自作
