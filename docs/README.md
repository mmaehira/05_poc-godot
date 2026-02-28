# ドキュメント一覧

このディレクトリには、プロジェクトの設計書とアセット生成ガイドが含まれています。

## 📁 ドキュメント構成

### アセット関連（⭐ 今すぐ使える）

| ドキュメント | 用途 | 読む順序 |
|------------|------|---------|
| [api-setup-guide.md](api-setup-guide.md) | **🚀 最初に読む（推奨）**<br>OpenAI APIで完全自動生成 | 1 |
| [asset-generation-quickstart.md](asset-generation-quickstart.md) | 手動生成ガイド<br>ChatGPT Plusで手動生成する場合 | 代替 |
| [dalle-prompts.md](dalle-prompts.md) | DALL-E用プロンプト全集<br>APIスクリプト内で使用 | 参考 |
| [asset-specifications.md](asset-specifications.md) | 技術仕様書<br>全アセットの詳細仕様（サイズ、フレーム数等） | 参考 |
| [asset-workflow.md](asset-workflow.md) | アセット準備ワークフロー<br>Claude Codeの役割と外部ツール連携 | 参考 |
| [asset-creation-guide.md](asset-creation-guide.md) | アセット作成ガイド<br>詳細な作成手順と命名規則 | 参考 |

### 設計書（将来的な拡張用）

これらのドキュメントは、CLAUDE.mdの指示に従って作成される予定です。

- `product-requirements.md` - プロダクト要求定義書
- `functional-design.md` - 機能設計書
- `architecture.md` - 技術仕様書
- `repository-structure.md` - リポジトリ構造定義書
- `development-guidelines.md` - 開発ガイドライン
- `glossary.md` - ユビキタス言語定義
- `release-strategy.md` - リリース戦略

---

## 🎯 アセット生成の始め方

### 🚀 推奨: OpenAI API で完全自動生成

**最も簡単で高速な方法です！**

#### ステップ1: APIセットアップ

[api-setup-guide.md](api-setup-guide.md) を読んで、OpenAI APIキーを設定します。

```bash
# APIキーを環境変数に設定
export OPENAI_API_KEY='sk-proj-your-api-key-here'

# 必要なライブラリをインストール
pip install openai pillow requests
```

#### ステップ2: アセットを自動生成

```bash
# 単一アセット生成
python3 scripts/dev/generate_asset_with_dalle.py --asset player_idle

# MVP一括生成（4アセット、約$0.16）
python3 scripts/dev/generate_asset_with_dalle.py --batch config/assets_batch_mvp.json

# 全キャラクター一括生成（13アセット、約$0.52）
python3 scripts/dev/generate_asset_with_dalle.py --batch config/assets_batch_full_characters.json
```

#### ステップ3: 検証

```bash
# アセット配置確認
bash scripts/dev/check_assets.sh
```

**メリット**:
- ✅ プロンプトのコピペ不要
- ✅ スプライトシート自動生成
- ✅ バッチ処理で大量生成可能
- ✅ コスト: 約$0.04/画像

---

### 📋 代替: 手動でChatGPT Plusを使用

APIを使わず、手動で生成したい場合は [asset-generation-quickstart.md](asset-generation-quickstart.md) を参照してください。

**デメリット**:
- ❌ 手動コピペが必要
- ❌ ダウンロード・配置が手動
- ❌ バッチ処理不可

---

## 🔗 関連ディレクトリ

### アセットディレクトリ

各ディレクトリにREADME.mdがあり、配置すべきファイルとプロンプトが記載されています。

```
assets/
├── characters/
│   ├── player/README.md          ← プレイヤーアセットガイド
│   ├── enemies/README.md         ← 敵アセットガイド
│   └── bosses/README.md          ← ボスアセットガイド
├── weapons/
│   └── projectiles/README.md     ← 発射物アセットガイド
├── items/README.md               ← アイテムアセットガイド
├── effects/                      ← エフェクトアセット
├── ui/                           ← UI素材
├── environment/                  ← 環境素材
└── audio/                        ← BGM/SE
    ├── bgm/
    └── se/
```

### 開発ツール

```
scripts/dev/
├── generate_asset_with_dalle.py  ← OpenAI API自動生成スクリプト（推奨）
├── check_assets.sh               ← アセット検証スクリプト
└── create_sprite_sheet.py        ← スプライトシート作成スクリプト
```

### バッチ生成設定

```
config/
├── assets_batch_mvp.json         ← MVP用（4アセット）
└── assets_batch_full_characters.json  ← 全キャラクター（13アセット）
```

---

## 📚 外部リソース

### 画像生成
- **ChatGPT Plus (DALL-E 3)**: https://chat.openai.com/

### 画像編集ツール
- **Aseprite** (有料、推奨): https://www.aseprite.org/
- **LibreSprite** (無料): https://libresprite.github.io/
- **Piskel** (ブラウザ、無料): https://www.piskelapp.com/
- **GIMP** (無料): https://www.gimp.org/
- **remove.bg** (背景削除): https://remove.bg/

### オーディオ素材
- **OpenGameArt**: https://opengameart.org/
- **Freesound**: https://freesound.org/
- **Incompetech**: https://incompetech.com/music/
- **JFXR** (レトロSE生成): https://jfxr.frozenfractal.com/

### 既存アセット
- **Kenney**: https://kenney.nl/assets
- **itch.io**: https://itch.io/game-assets/free

---

## ❓ よくある質問

### Q: どのドキュメントから読むべき？

**A**: [asset-generation-quickstart.md](asset-generation-quickstart.md) を最初に読んでください。
すぐにアセット生成を始められます。

### Q: DALL-Eでスプライトシートは生成できる？

**A**: 困難です。単一フレームを生成し、Pythonスクリプトまたは画像編集ソフトでスプライトシート化してください。

### Q: オーディオ素材はどうする？

**A**: DALL-Eは画像のみです。OpenGameArtやFreesoundから無料素材を取得してください。

### Q: 生成した画像サイズが違う

**A**: ImageMagickやPillowでNearest Neighbor法を使ってリサイズしてください。

### Q: プレースホルダーで開発できる？

**A**: 可能です。Godotの ColorRect や単色画像で開発を進め、後でアセット差し替えできます。

---

## 🎯 次のアクション

### API自動生成（推奨）

1. ✅ このREADMEを読む
2. ⬜ [api-setup-guide.md](api-setup-guide.md) を読む
3. ⬜ OpenAI APIキーを取得・設定
4. ⬜ Pythonライブラリをインストール
5. ⬜ テスト実行: `python3 scripts/dev/generate_asset_with_dalle.py --asset player_idle`
6. ⬜ MVP生成: `python3 scripts/dev/generate_asset_with_dalle.py --batch config/assets_batch_mvp.json`
7. ⬜ 検証: `bash scripts/dev/check_assets.sh`
8. ⬜ Godotでゲーム確認

### 手動生成（代替）

1. ✅ このREADMEを読む
2. ⬜ [asset-generation-quickstart.md](asset-generation-quickstart.md) を読む
3. ⬜ ChatGPT Plusでアセット生成
4. ⬜ 検証: `bash scripts/dev/check_assets.sh`
5. ⬜ Godotでゲーム確認

---

**プロジェクト全体のルール**: [../CLAUDE.md](../CLAUDE.md)
**アセット配置ルール**: [../assets/README.md](../assets/README.md)
