# OpenAI API セットアップガイド

このガイドでは、OpenAI APIを使用してDALL-E 3で自動的にアセットを生成する環境をセットアップします。

## 🎯 概要

**メリット**:
- ✅ **完全自動化**: プロンプトをコピペする必要なし
- ✅ **バッチ生成**: 複数アセットを一度に生成可能
- ✅ **スクリプト化**: CIや開発フローに統合可能
- ✅ **スプライトシート自動生成**: 単一フレーム → スプライトシート化まで自動

**コスト**:
- DALL-E 3: **$0.04/画像** (標準品質、1024×1024)
- DALL-E 3 HD: **$0.08/画像** (高品質)
- MVP（4アセット）: 約 **$0.16 USD**
- フルキャラクターセット（13アセット）: 約 **$0.52 USD**

---

## 📋 前提条件

### 1. OpenAI アカウント

1. https://platform.openai.com/ にアクセス
2. アカウント作成（または既存アカウントでログイン）
3. 支払い方法を登録（APIクレジット購入が必要）

### 2. APIキーの取得

1. https://platform.openai.com/api-keys にアクセス
2. "Create new secret key" をクリック
3. キー名を入力（例: "godot-game-assets"）
4. 生成されたAPIキーをコピー（後で確認できないので注意！）

**例**: `sk-proj-abc123...xyz789`

### 3. 必要なPythonライブラリ

```bash
# 必要なライブラリをインストール
pip install openai pillow requests
```

---

## 🔧 セットアップ手順

### 方法A: 環境変数で設定（推奨）

#### Linux / macOS

```bash
# ~/.bashrc または ~/.zshrc に追加
export OPENAI_API_KEY='sk-proj-your-actual-api-key-here'

# 設定を反映
source ~/.bashrc  # または source ~/.zshrc
```

#### Windows (PowerShell)

```powershell
# 環境変数を設定
$env:OPENAI_API_KEY = "sk-proj-your-actual-api-key-here"

# 永続化（システム全体）
[System.Environment]::SetEnvironmentVariable('OPENAI_API_KEY', 'sk-proj-your-actual-api-key-here', 'User')
```

#### 確認

```bash
# APIキーが設定されているか確認
echo $OPENAI_API_KEY
```

### 方法B: .env ファイル（開発用）

```bash
# プロジェクトルートに .env ファイルを作成
cd /workspaces/05_poc-godot
cat > .env << 'EOF'
OPENAI_API_KEY=sk-proj-your-actual-api-key-here
EOF

# .gitignore に追加（APIキーを誤ってコミットしないため）
echo ".env" >> .gitignore
```

**注意**: この方法はスクリプト内で `python-dotenv` を使用する必要があります。

---

## 🚀 使用方法

### 基本: 単一アセット生成

```bash
cd /workspaces/05_poc-godot

# プレイヤーキャラクター（Idle）を生成
python3 scripts/dev/generate_asset_with_dalle.py --asset player_idle

# 基本敵を生成
python3 scripts/dev/generate_asset_with_dalle.py --asset basic_enemy
```

**実行内容**:
1. DALL-E 3 APIで画像生成
2. 画像をダウンロード
3. 単一フレームを保存
4. スプライトシートを自動生成（フレーム数が指定されている場合）

### バッチ生成: MVP（最小セット）

```bash
# MVP用のアセット一括生成（4アセット）
python3 scripts/dev/generate_asset_with_dalle.py \
    --batch config/assets_batch_mvp.json

# 所要時間: 20-30分
# コスト: 約$0.16 USD
```

**生成されるアセット**:
- プレイヤー idle
- 基本敵
- 直線弾
- 経験値オーブ（小）

### バッチ生成: フルキャラクターセット

```bash
# 全キャラクター一括生成（13アセット）
python3 scripts/dev/generate_asset_with_dalle.py \
    --batch config/assets_batch_full_characters.json

# 所要時間: 1-2時間
# コスト: 約$0.52 USD
```

### カスタムプロンプト生成

```bash
# 独自プロンプトで生成
python3 scripts/dev/generate_asset_with_dalle.py \
    --prompt "64x64 pixel art dragon, top-down view, breathing fire" \
    --output assets/characters/custom_dragon.png
```

### 利用可能なアセット一覧

```bash
# 定義済みアセットのリストを表示
python3 scripts/dev/generate_asset_with_dalle.py --list
```

**出力例**:
```
Available assets:
  - player_idle        (4f)
  - player_walk        (4f)
  - player_hit         (2f)
  - basic_enemy        (4f)
  - strong_enemy       (4f)
  - fast_enemy         (4f)
  - heavy_enemy        (4f)
  - tank_boss          (6f)
  - sniper_boss        (6f)
  - swarm_boss         (6f)
  - straight_shot      (static)
  - area_blast         (4f)
  - exp_orb_small      (4f)
  - exp_orb_medium     (4f)
```

---

## 🔧 高度な使用方法

### オプション一覧

```bash
python3 scripts/dev/generate_asset_with_dalle.py --help
```

| オプション | 説明 | 例 |
|-----------|------|-----|
| `--asset NAME` | 定義済みアセットを生成 | `--asset player_idle` |
| `--prompt TEXT` | カスタムプロンプトで生成 | `--prompt "32x32 slime"` |
| `--output PATH` | 出力先パス（--promptと併用） | `--output assets/custom.png` |
| `--batch FILE` | バッチ生成（JSONまたはカンマ区切り） | `--batch mvp.json` |
| `--list` | 利用可能なアセット一覧 | - |
| `--no-sprite-sheet` | スプライトシート生成を無効化 | - |
| `--delay N` | バッチ生成時の待機時間（秒） | `--delay 10` |

### カンマ区切りでバッチ生成

```bash
# JSONファイル不要、直接指定
python3 scripts/dev/generate_asset_with_dalle.py \
    --batch "player_idle,basic_enemy,exp_orb_small"
```

### 待機時間を調整

```bash
# APIレート制限対策（デフォルト: 5秒）
python3 scripts/dev/generate_asset_with_dalle.py \
    --batch config/assets_batch_mvp.json \
    --delay 10
```

---

## 📊 コスト管理

### 料金体系

| モデル | サイズ | 品質 | 料金 |
|--------|--------|------|------|
| DALL-E 3 | 1024×1024 | Standard | **$0.04/画像** |
| DALL-E 3 | 1024×1024 | HD | $0.08/画像 |
| DALL-E 3 | 1024×1792 | Standard | $0.08/画像 |
| DALL-E 3 | 1792×1024 | Standard | $0.08/画像 |

### 推奨設定

本プロジェクトでは **Standard品質、1024×1024** を使用（最安）

### 見積もり

| フェーズ | アセット数 | 推定コスト |
|---------|-----------|-----------|
| MVP | 4 | $0.16 |
| Phase 1（キャラクター全種） | 13 | $0.52 |
| Phase 2（武器・アイテム追加） | 20 | $0.80 |
| Phase 3（エフェクト追加） | 30 | $1.20 |
| **全アセット** | 50-60 | **$2.00-2.40** |

### 使用量確認

https://platform.openai.com/usage でリアルタイム使用量を確認できます。

---

## 🛠️ トラブルシューティング

### Q1: "API key not found" エラー

**原因**: 環境変数が設定されていない

**解決策**:
```bash
# APIキーを設定
export OPENAI_API_KEY='sk-proj-your-key'

# 確認
echo $OPENAI_API_KEY
```

### Q2: "Rate limit exceeded" エラー

**原因**: APIレート制限に到達

**解決策**:
```bash
# 待機時間を増やす
python3 scripts/dev/generate_asset_with_dalle.py \
    --batch mvp.json \
    --delay 15
```

または、OpenAIダッシュボードでTier（利用枠）を確認:
https://platform.openai.com/settings/organization/limits

### Q3: "Insufficient credits" エラー

**原因**: APIクレジット残高不足

**解決策**:
1. https://platform.openai.com/settings/organization/billing にアクセス
2. "Add payment method" でクレジットカード登録
3. "Add credits" で追加購入（最小$5）

### Q4: 生成された画像が期待と違う

**原因**: DALL-E 3の出力にはランダム性がある

**解決策**:
```bash
# 同じアセットを再生成
python3 scripts/dev/generate_asset_with_dalle.py --asset player_idle

# 毎回異なる画像が生成される
```

気に入った画像が出るまで再実行してください。

### Q5: スプライトシートがおかしい

**原因**: 生成画像のサイズが想定と異なる

**解決策**:
```bash
# スプライトシート生成を無効化して、手動で修正
python3 scripts/dev/generate_asset_with_dalle.py \
    --asset player_idle \
    --no-sprite-sheet

# 単一フレームを手動でリサイズしてから
python3 scripts/dev/create_sprite_sheet.py \
    assets/characters/player/player_idle_single.png \
    assets/characters/player/player_idle_48x48_4f.png \
    4
```

---

## 🔒 セキュリティのベストプラクティス

### APIキーの保護

1. **絶対にGitにコミットしない**
   ```bash
   # .gitignore に追加
   .env
   **/api_key.txt
   ```

2. **環境変数で管理**
   - ハードコードしない
   - `.env` ファイルは `.gitignore` に追加

3. **定期的にローテーション**
   - 3-6ヶ月ごとにAPIキーを再生成
   - 古いキーを削除

4. **権限を最小化**
   - OpenAIの設定で使用制限を設定
   - 月間予算を設定

### 予算アラート設定

1. https://platform.openai.com/settings/organization/billing/limits にアクセス
2. "Set a monthly budget" で上限を設定（例: $10/月）
3. 上限に達したら自動停止

---

## 📚 関連ドキュメント

- [dalle-prompts.md](dalle-prompts.md) - 全プロンプト定義
- [asset-specifications.md](asset-specifications.md) - アセット仕様
- [asset-generation-quickstart.md](asset-generation-quickstart.md) - 手動生成ガイド（旧）

---

## 🎯 次のステップ

1. ✅ このガイドを読む
2. ⬜ OpenAI APIキーを取得
3. ⬜ 環境変数を設定
4. ⬜ Pythonライブラリをインストール
5. ⬜ テスト実行（単一アセット）
   ```bash
   python3 scripts/dev/generate_asset_with_dalle.py --asset player_idle
   ```
6. ⬜ MVP生成
   ```bash
   python3 scripts/dev/generate_asset_with_dalle.py --batch config/assets_batch_mvp.json
   ```
7. ⬜ アセット検証
   ```bash
   bash scripts/dev/check_assets.sh
   ```
8. ⬜ Godotで動作確認

---

**完全自動化でアセット生成を始めましょう！** 🚀
