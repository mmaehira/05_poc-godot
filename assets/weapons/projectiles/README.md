# Weapon Projectile Assets

このディレクトリには、武器の発射物スプライトを配置します。

## 📋 必要なファイル

### 静止画（アニメーション無し）
- [ ] `straight_shot_projectile_16x16.png` (16×16) - 直線弾
- [ ] `laser_beam_projectile_8x32.png` (8×32) - レーザービーム

### アニメーション付き（4フレーム）
- [ ] `area_blast_projectile_24x24_4f.png` (96×24) - 範囲攻撃弾
- [ ] `homing_missile_projectile_20x20_4f.png` (80×20) - 追尾ミサイル
- [ ] `lightning_projectile_16x48_4f.png` (64×48) - 雷撃
- [ ] `orbital_projectile_20x20_4f.png` (80×20) - 周回弾

## 🎨 DALL-E生成プロンプト

### Straight Shot（直線弾）
```
Create a 16x16 pixel art sprite of a simple energy projectile, viewed from top-down perspective, pointing upward. The projectile should be a glowing blue/cyan energy orb or bolt. Use an 8-color palette. Transparent background, PNG format. Single sprite, suitable for rapid-fire weapon.
```

### Area Blast（範囲攻撃弾）
```
Create a 24x24 pixel art sprite of an explosive fireball projectile, viewed from top-down perspective. The fireball should be orange and yellow with a swirling pattern. Use a 12-color palette. Transparent background, PNG format. Single sprite. Make it look like it will explode on impact.
```

### Homing Missile（追尾ミサイル）
```
Create a 20x20 pixel art sprite of a magical homing missile, viewed from top-down perspective, pointing upward. The missile should be purple with glowing trailing particles. Use a 12-color palette. Transparent background, PNG format. Single sprite. Make it look mystical and fast.
```

### Laser Beam（レーザー）
```
Create an 8x32 pixel art sprite of a thin laser beam, viewed from top-down perspective, vertical orientation. The laser should be bright cyan or red with a glowing core. Use a 6-color palette. Transparent background, PNG format. Single sprite, elongated vertical shape.
```

### Lightning（雷撃）
```
Create a 16x48 pixel art sprite of a lightning bolt, viewed from top-down perspective, vertical orientation. The lightning should be bright yellow/white with jagged edges. Use an 8-color palette. Transparent background, PNG format. Single sprite, make it look electric and dangerous.
```

### Orbital（周回弾）
```
Create a 20x20 pixel art sprite of a magical orb that orbits the player, viewed from top-down perspective. The orb should be glowing purple or blue with sparkle effects. Use a 10-color palette. Transparent background, PNG format. Single sprite. Make it look protective and magical.
```

## 📊 発射物仕様

| 武器 | サイズ | シートサイズ | アニメ | FPS | 回転 |
|------|--------|------------|--------|-----|------|
| Straight Shot | 16×16 | - | 無 | - | rotation使用 |
| Area Blast | 24×24 | 96×24 | 4f | 12 | 不要（全方向） |
| Homing | 20×20 | 80×20 | 4f | 10 | rotation使用 |
| Laser | 8×32 | - | 無 | - | rotation使用 |
| Lightning | 16×48 | 64×48 | 4f | 15 | rotation使用 |
| Orbital | 20×20 | 80×20 | 4f | 12 | アニメ内包 |

**共通制約**:
- 同時表示500発想定
- 全てloop再生（アニメーション有の場合）
- 上向き基準で作成

## 📚 参考資料

- [docs/asset-specifications.md](../../../docs/asset-specifications.md#4-weaponprojectile) - 詳細仕様
- [docs/dalle-prompts.md](../../../docs/dalle-prompts.md#weapon) - プロンプト全文
