# Player Character Assets

このディレクトリには、プレイヤーキャラクターのスプライトを配置します。

## 📋 必要なファイル

### スプライトシート
- [ ] `player_idle_48x48_4f.png` (192×48) - 待機アニメーション
- [ ] `player_walk_48x48_4f.png` (192×48) - 移動アニメーション
- [ ] `player_hit_48x48_2f.png` (96×48) - 被弾アニメーション

### SpriteFrames リソース
- [ ] `player_frames.tres` - AnimatedSprite2D用のSpriteFramesリソース

## 🎨 DALL-E生成手順

### ステップ1: ChatGPT Plusでプロンプトを実行

**Idle（待機）用プロンプト**:
```
Create a 48x48 pixel art sprite of a fantasy warrior character in idle pose, viewed from top-down perspective. The character should be facing upward. Use a vibrant 16-color palette with a blue and silver color scheme. The sprite should have a clear silhouette with sharp, clean pixel art style. Transparent background, PNG format. Single sprite, no animation frames. Make it suitable for a vampire survivors-style game.
```

**Walk（移動）用プロンプト**:
```
Create a 48x48 pixel art sprite of a fantasy warrior character in walking pose, viewed from top-down perspective. The character should be facing upward, with one leg forward suggesting forward movement. Use a vibrant 16-color palette with a blue and silver color scheme. The sprite should have a clear silhouette with sharp, clean pixel art style. Transparent background, PNG format. Single sprite, no animation frames.
```

**Hit（被弾）用プロンプト**:
```
Create a 48x48 pixel art sprite of a fantasy warrior character in hit/damage pose, viewed from top-down perspective. The character should be facing upward, with a recoiling motion. Add a slight red flash effect. Use a vibrant 16-color palette with a blue and silver color scheme. Transparent background, PNG format. Single sprite, no animation frames.
```

### ステップ2: 画像をダウンロード

生成された画像を以下の仮名でダウンロード:
- `player_idle_single.png`
- `player_walk_single.png`
- `player_hit_single.png`

### ステップ3: スプライトシート化（手動）

**オプションA: Aseprite使用**
1. 新規ファイル作成: 192×48（idle/walk用）または 96×48（hit用）
2. 生成した単一フレームを必要回数コピーして横並び配置
3. エクスポート: `player_idle_48x48_4f.png`

**オプションB: GIMP/Photoshop使用**
1. 新規キャンバス作成
2. レイヤーとして単一フレームを配置
3. 必要回数複製して横並び配置
4. PNG形式でエクスポート

**オプションC: Pythonスクリプト使用**
```python
from PIL import Image

# 単一フレームを読み込み
frame = Image.open("player_idle_single.png")
width, height = frame.size

# 4フレーム分のスプライトシート作成
sprite_sheet = Image.new("RGBA", (width * 4, height))
for i in range(4):
    sprite_sheet.paste(frame, (width * i, 0))

sprite_sheet.save("player_idle_48x48_4f.png")
```

### ステップ4: このディレクトリに配置

生成したスプライトシートをこのディレクトリに配置:
```
assets/characters/player/
├── player_idle_48x48_4f.png
├── player_walk_48x48_4f.png
├── player_hit_48x48_2f.png
└── README.md (このファイル)
```

### ステップ5: Godotで確認

```bash
# Godotエディタを開いてインポート確認
godot --editor --path /workspaces/05_poc-godot
```

インポート設定を確認:
- **Filter**: Nearest
- **Mipmaps**: Generate = false
- **Compression**: VRAM Compressed

## 🔧 仕様詳細

| 項目 | idle | walk | hit |
|------|------|------|-----|
| 1フレームサイズ | 48×48 | 48×48 | 48×48 |
| シートサイズ | 192×48 | 192×48 | 96×48 |
| フレーム数 | 4 | 4 | 2 |
| FPS | 8 | 12 | 15 |
| ループ | loop | loop | one-shot |
| 向き | 上向き固定 | 上向き固定 | 上向き固定 |

**注意**: スプライトは上向き固定です。Godot側で `rotation` を使用して全方向に対応します。

## 📚 参考資料

- [docs/asset-specifications.md](../../../docs/asset-specifications.md#1-player) - 詳細仕様
- [docs/dalle-prompts.md](../../../docs/dalle-prompts.md#1-player) - プロンプト全文
