# アセット生成クイックスタートガイド

このガイドでは、ChatGPT Plus（DALL-E 3）を使用してゲームアセットを効率的に生成する手順を説明します。

## 🎯 概要

**目標**: DALL-E 3で画像を生成し、Godotで使用可能なアセットに変換する

**所要時間**: 1アセットあたり5-10分

**必要なもの**:
- ChatGPT Plus アカウント
- 画像編集ソフト（Aseprite推奨、またはGIMP/Photoshop）
- Python 3（スプライトシート自動化用、オプション）

---

## 📝 基本ワークフロー

### ステップ1: プロンプトを取得

[docs/dalle-prompts.md](dalle-prompts.md) から必要なアセットのプロンプトをコピー

**例: プレイヤーキャラクター（Idle）**
```
Create a 48x48 pixel art sprite of a fantasy warrior character in idle pose, viewed from top-down perspective. The character should be facing upward. Use a vibrant 16-color palette with a blue and silver color scheme. The sprite should have a clear silhouette with sharp, clean pixel art style. Transparent background, PNG format. Single sprite, no animation frames. Make it suitable for a vampire survivors-style game.
```

### ステップ2: ChatGPT Plusで生成

1. ChatGPT Plus（https://chat.openai.com/）にアクセス
2. プロンプトを貼り付けて送信
3. 生成された画像を確認
4. 気に入らない場合は「もう一度生成して」と依頼

### ステップ3: 画像をダウンロード

- 生成された画像をクリック
- 右クリック → 「名前を付けて画像を保存」
- 仮名で保存（例: `player_idle_single.png`）

### ステップ4: スプライトシート化

**方法A: Pythonスクリプト使用（推奨・自動）**

```bash
cd /workspaces/05_poc-godot

# Pillowライブラリをインストール（初回のみ）
pip install Pillow

# スプライトシート作成（4フレーム）
python3 scripts/dev/create_sprite_sheet.py \
    ~/Downloads/player_idle_single.png \
    assets/characters/player/player_idle_48x48_4f.png \
    4
```

**方法B: Aseprite使用（手動）**

1. Asepriteを起動
2. `File → New` → 幅を `フレーム数 × 1フレームサイズ` に設定
   - 例: 4フレーム × 48px = 192px幅、48px高さ
3. 生成した単一フレームを開く
4. コピー＆ペーストで4回横並びに配置
5. `File → Export → Export As` → PNG形式で保存

**方法C: GIMP/Photoshop使用（手動）**

1. 新規キャンバス作成（例: 192×48）
2. 生成画像をレイヤーとして配置
3. レイヤー複製 → 横に移動（48px, 96px, 144px）
4. レイヤー統合
5. PNG形式でエクスポート

### ステップ5: 配置と検証

```bash
# アセットを適切なディレクトリに配置済みか確認
bash scripts/dev/check_assets.sh
```

### ステップ6: Godotでインポート確認

```bash
# Godotエディタを開く
godot --editor --path /workspaces/05_poc-godot
```

インポート設定を確認:
1. `FileSystem` ドックでアセットを選択
2. `Import` タブで設定確認
   - **Filter**: Nearest
   - **Mipmaps**: Generate = false
   - **Compression**: VRAM Compressed

---

## 🎮 優先順位別アセット生成ガイド

### フェーズ1: 最小限の動作確認（MVP）

**所要時間: 1-2時間**

最小限のアセットでゲームを動作させる:

1. **プレイヤー（1種類のみ）**
   - `player_idle_48x48_4f.png`

2. **敵（基本敵のみ）**
   - `basic_enemy_idle_32x32_4f.png`

3. **発射物（1種類のみ）**
   - `straight_shot_projectile_16x16.png`

4. **経験値オーブ（小のみ）**
   - `exp_orb_small_12x12_4f.png`

**手順**:
```bash
# 1. プレイヤー生成
# ChatGPTでプロンプト実行 → player_idle_single.png をダウンロード
python3 scripts/dev/create_sprite_sheet.py \
    ~/Downloads/player_idle_single.png \
    assets/characters/player/player_idle_48x48_4f.png 4

# 2. 基本敵生成
# ChatGPTでプロンプト実行 → basic_enemy_single.png をダウンロード
python3 scripts/dev/create_sprite_sheet.py \
    ~/Downloads/basic_enemy_single.png \
    assets/characters/enemies/basic_enemy_idle_32x32_4f.png 4

# 3. 発射物生成（単一フレーム）
# ChatGPTでプロンプト実行 → straight_shot.png をダウンロード
cp ~/Downloads/straight_shot.png \
    assets/weapons/projectiles/straight_shot_projectile_16x16.png

# 4. 経験値オーブ生成
# ChatGPTでプロンプト実行 → exp_orb_small_single.png をダウンロード
python3 scripts/dev/create_sprite_sheet.py \
    ~/Downloads/exp_orb_small_single.png \
    assets/items/exp_orb_small_12x12_4f.png 4

# 5. 検証
bash scripts/dev/check_assets.sh
```

### フェーズ2: 主要ゲームプレイ拡充

**所要時間: 3-5時間**

ゲームプレイの多様性を追加:

5. **プレイヤー（全アニメーション）**
   - Walk, Hit追加

6. **敵（全4種類）**
   - Strong, Fast, Heavy追加

7. **発射物（全6種類）**
   - Area Blast, Homing, Laser, Lightning, Orbital追加

8. **アイテム（全種類）**
   - EXP中・大、Powerup, Magnet追加

### フェーズ3: ビジュアルポリッシュ

**所要時間: 4-6時間**

ビジュアル品質向上:

9. **ボス（全3種類）**
   - Tank, Sniper, Swarm Boss

10. **エフェクト（全種類）**
    - Explosion, Muzzle Flash, Level Up, Hit Spark, Powerup Aura
    - パーティクル5種

11. **UI素材**
    - ボタン、パネル、ゲージ類

### フェーズ4: 環境・オーディオ

**所要時間: 6-10時間**

環境とサウンド:

12. **環境素材**
    - タイルセット、装飾

13. **オーディオ**
    - BGM 3曲
    - SE 13種類

**注意**: オーディオはDALL-Eでは生成できません。OpenGameArt等から取得してください。

---

## 💡 プロ向けTips

### Tip 1: バッチ生成

複数のアセットを一度に依頼:

```
以下の5つのスプライトを生成してください:
1. 48x48 pixel art fantasy warrior (idle pose, top-down, facing up)
2. 48x48 pixel art fantasy warrior (walking pose, top-down, facing up)
3. 48x48 pixel art fantasy warrior (hit pose, top-down, facing up)
4. 32x32 pixel art slime monster (top-down, facing up)
5. 16x16 pixel art energy projectile (glowing blue, pointing up)

全て透過背景、16色パレット、ピクセルアート。
```

### Tip 2: プロンプト調整

生成結果が期待と異なる場合:

**色調整**:
```
同じデザインで、色を赤とゴールドに変更してください
```

**サイズ調整**:
```
同じデザインで、より大きく（96x96ピクセル）生成してください
```

**ディテール追加**:
```
同じキャラクターに剣と盾を持たせてください
```

### Tip 3: 一貫性の維持

同じキャラクターの複数ポーズを生成する場合:

```
先ほど生成したファンタジー戦士と同じデザイン・色で、
今度は歩行ポーズを生成してください。
同じ青とシルバーの配色、同じ鎧のデザインを維持してください。
```

### Tip 4: バリエーション生成

敵の色違いバリエーション:

```
先ほどのスライムモンスターと同じ形状で、
色だけ赤に変更したバージョンを生成してください。
```

---

## 🔧 トラブルシューティング

### Q1: 生成されたサイズが指定と異なる

**問題**: DALL-E 3は正確なピクセルサイズを保証しない

**解決策**:
```bash
# ImageMagickでリサイズ（Nearest Neighbor法）
convert input.png -sample 48x48 output.png

# Pythonでリサイズ
python3 -c "
from PIL import Image
img = Image.open('input.png')
img = img.resize((48, 48), Image.NEAREST)
img.save('output.png')
"
```

### Q2: 透過背景がない

**問題**: 背景が白または他の色で塗りつぶされている

**解決策A: remove.bg使用（オンライン）**
1. https://remove.bg/ にアクセス
2. 画像をアップロード
3. 背景削除された画像をダウンロード

**解決策B: GIMP使用（手動）**
1. GIMPで画像を開く
2. `Layer → Transparency → Add Alpha Channel`
3. `Select → By Color` → 背景色をクリック
4. `Delete` キーで削除
5. PNG形式でエクスポート

### Q3: ピクセルアートがぼやけている

**問題**: DALL-E 3が高解像度でスムーズな画像を生成

**解決策A: Asepriteで再ピクセル化**
1. Asepriteで開く
2. `Sprite → Sprite Size` → Nearest Neighbor法でリサイズ
3. 手動でドット打ち直し

**解決策B: インデックスカラー化（GIMP）**
1. `Image → Mode → Indexed`
2. カラー数を16色に制限
3. `Image → Mode → RGB`で戻す
4. PNG形式でエクスポート

### Q4: スプライトシートのフレーム間がズレる

**問題**: 手動配置で位置がズレた

**解決策**: Pythonスクリプト使用
```bash
python3 scripts/dev/create_sprite_sheet.py input.png output.png 4
```

### Q5: Godotでインポートがぼやける

**問題**: Filter設定がLinearになっている

**解決策**:
1. Godotで画像を選択
2. `Import` タブ
3. `Filter` を `Nearest` に変更
4. `Reimport` クリック

---

## 📚 参考資料

### 社内ドキュメント
- [docs/asset-specifications.md](asset-specifications.md) - 技術仕様書
- [docs/dalle-prompts.md](dalle-prompts.md) - プロンプト全集
- [docs/asset-workflow.md](asset-workflow.md) - 詳細ワークフロー

### 各アセットディレクトリのREADME
- [assets/characters/player/README.md](../assets/characters/player/README.md)
- [assets/characters/enemies/README.md](../assets/characters/enemies/README.md)
- [assets/characters/bosses/README.md](../assets/characters/bosses/README.md)
- [assets/weapons/projectiles/README.md](../assets/weapons/projectiles/README.md)
- [assets/items/README.md](../assets/items/README.md)

### ツール
- **ChatGPT Plus**: https://chat.openai.com/
- **Aseprite**: https://www.aseprite.org/ (有料)
- **LibreSprite**: https://libresprite.github.io/ (無料)
- **Piskel**: https://www.piskelapp.com/ (ブラウザ版、無料)
- **GIMP**: https://www.gimp.org/ (無料)
- **remove.bg**: https://remove.bg/ (背景削除、無料枠あり)

### アセット入手先（オーディオ・代替）
- **OpenGameArt**: https://opengameart.org/
- **Kenney**: https://kenney.nl/assets
- **itch.io**: https://itch.io/game-assets/free
- **Freesound**: https://freesound.org/

---

## 🎯 次のアクション

1. ✅ このガイドを確認
2. ⬜ [docs/dalle-prompts.md](dalle-prompts.md) を開く
3. ⬜ フェーズ1のプロンプトをコピー
4. ⬜ ChatGPT Plusで生成開始
5. ⬜ スプライトシート化スクリプト実行
6. ⬜ アセット検証スクリプト実行
7. ⬜ Godotでゲーム確認

**質問・トラブル時は、各アセットディレクトリのREADME.mdを参照してください。**

Happy Asset Creating! 🎨
