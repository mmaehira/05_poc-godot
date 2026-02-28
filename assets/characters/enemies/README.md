# Enemy Character Assets

このディレクトリには、敵キャラクターのスプライトを配置します。

## 📋 必要なファイル

### Basic Enemy（基本敵）
- [ ] `basic_enemy_idle_32x32_4f.png` (128×32) - 待機アニメーション
- [ ] `basic_enemy_frames.tres` - SpriteFramesリソース

### Strong Enemy（強敵）
- [ ] `strong_enemy_idle_40x40_4f.png` (160×40) - 待機アニメーション
- [ ] `strong_enemy_frames.tres` - SpriteFramesリソース

### Fast Enemy（高速敵）
- [ ] `fast_enemy_idle_28x28_4f.png` (112×28) - 待機アニメーション
- [ ] `fast_enemy_frames.tres` - SpriteFramesリソース

### Heavy Enemy（重量敵）
- [ ] `heavy_enemy_idle_56x56_4f.png` (224×56) - 待機アニメーション
- [ ] `heavy_enemy_frames.tres` - SpriteFramesリソース

## 🎨 DALL-E生成プロンプト

### Basic Enemy
```
Create a 32x32 pixel art sprite of a small slime monster, viewed from top-down perspective, facing upward. The slime should be green with a simple cute design. Use a 12-color palette. Transparent background, PNG format. Single sprite, no animation frames. Make it suitable for a vampire survivors-style enemy that appears in large numbers.
```

### Strong Enemy
```
Create a 40x40 pixel art sprite of a skeleton warrior, viewed from top-down perspective, facing upward. The skeleton should hold a sword and shield, with white bones and dark armor accents. Use a 16-color palette. Transparent background, PNG format. Single sprite, no animation frames. Make it look tougher than basic enemies.
```

### Fast Enemy
```
Create a 28x28 pixel art sprite of a small bat creature, viewed from top-down perspective, facing upward. The bat should have spread wings suggesting fast movement, with purple and black colors. Use a 12-color palette. Transparent background, PNG format. Single sprite, no animation frames. Make it look agile and fast.
```

### Heavy Enemy
```
Create a 56x56 pixel art sprite of a large orc warrior, viewed from top-down perspective, facing upward. The orc should be bulky and intimidating, with green skin and heavy armor. Use a 16-color palette. Transparent background, PNG format. Single sprite, no animation frames. Make it look slow but powerful.
```

## 📊 敵タイプ別仕様

| タイプ | サイズ | シートサイズ | フレーム数 | FPS | 同時表示数 |
|--------|--------|------------|-----------|-----|-----------|
| Basic  | 32×32  | 128×32     | 4         | 8   | 200体想定 |
| Strong | 40×40  | 160×40     | 4         | 8   | 50体想定  |
| Fast   | 28×28  | 112×28     | 4         | 12  | 100体想定 |
| Heavy  | 56×56  | 224×56     | 4         | 6   | 30体想定  |

**共通仕様**:
- 全て上向き固定
- Godot側で `look_at(player)` または `rotation` 使用
- 全てloop再生

## 📚 参考資料

- [docs/asset-specifications.md](../../../docs/asset-specifications.md#2-enemy) - 詳細仕様
- [docs/dalle-prompts.md](../../../docs/dalle-prompts.md#2-enemy) - プロンプト全文
