# Item Assets

このディレクトリには、アイテムスプライトを配置します。

## 📋 必要なファイル

### 経験値オーブ
- [ ] `exp_orb_small_12x12_4f.png` (48×12) - 小オーブ
- [ ] `exp_orb_medium_16x16_4f.png` (64×16) - 中オーブ
- [ ] `exp_orb_large_20x20_4f.png` (80×20) - 大オーブ

### その他アイテム
- [ ] `powerup_item_24x24_4f.png` (96×24) - パワーアップ
- [ ] `magnet_item_24x24_4f.png` (96×24) - マグネット

## 🎨 DALL-E生成プロンプト

### EXP Orb Small
```
Create a 12x12 pixel art sprite of a small glowing experience orb, viewed from top-down perspective. The orb should be bright yellow or gold with a gentle glow. Use an 8-color palette. Transparent background, PNG format. Single sprite. Make it small and collectible.
```

### EXP Orb Medium
```
Create a 16x16 pixel art sprite of a medium glowing experience orb, viewed from top-down perspective. The orb should be bright green with a stronger glow than the small version. Use a 10-color palette. Transparent background, PNG format. Single sprite. Make it more valuable-looking than the small orb.
```

### EXP Orb Large
```
Create a 20x20 pixel art sprite of a large glowing experience orb, viewed from top-down perspective. The orb should be bright blue or cyan with the strongest glow. Use a 12-color palette. Transparent background, PNG format. Single sprite. Make it look very valuable and rare.
```

### Powerup
```
Create a 24x24 pixel art sprite of a powerup item, viewed from top-down perspective. The item should be a glowing red crystal or potion bottle with sparkle effects. Use a 12-color palette. Transparent background, PNG format. Single sprite. Make it look powerful and temporary.
```

### Magnet
```
Create a 24x24 pixel art sprite of a magnet item, viewed from top-down perspective. The item should be a stylized magnet with magnetic field lines or sparkles around it. Use red, blue, and white colors. Use a 10-color palette. Transparent background, PNG format. Single sprite. Make it look like it attracts items.
```

## 📊 アイテム仕様

| アイテム | サイズ | シートサイズ | フレーム数 | FPS | 同時表示数 |
|---------|--------|------------|-----------|-----|-----------|
| EXP Small | 12×12 | 48×12 | 4 | 8 | 200個想定 |
| EXP Medium | 16×16 | 64×16 | 4 | 8 | 200個想定 |
| EXP Large | 20×20 | 80×20 | 4 | 8 | 200個想定 |
| Powerup | 24×24 | 96×24 | 4 | 12 | 10個想定 |
| Magnet | 24×24 | 96×24 | 4 | 12 | 10個想定 |

**共通仕様**:
- 全てloop再生
- 回転不要（全方向対応）
- アニメーションは回転や輝きエフェクト

## 📚 参考資料

- [docs/asset-specifications.md](../../../docs/asset-specifications.md#5-item) - 詳細仕様
- [docs/dalle-prompts.md](../../../docs/dalle-prompts.md#item) - プロンプト全文
