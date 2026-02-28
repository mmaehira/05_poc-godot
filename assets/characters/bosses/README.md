# Boss Character Assets

このディレクトリには、ボス敵のスプライトを配置します。

## 📋 必要なファイル

### Tank Boss（戦車型ボス）
- [ ] `tank_boss_idle_96x96_6f.png` (576×96) - 待機アニメーション
- [ ] `tank_boss_frames.tres` - SpriteFramesリソース

### Sniper Boss（狙撃型ボス）
- [ ] `sniper_boss_idle_80x80_6f.png` (480×80) - 待機アニメーション
- [ ] `sniper_boss_frames.tres` - SpriteFramesリソース

### Swarm Boss（群れ型ボス）
- [ ] `swarm_boss_idle_88x88_6f.png` (528×88) - 待機アニメーション
- [ ] `swarm_boss_frames.tres` - SpriteFramesリソース

## 🎨 DALL-E生成プロンプト

### Tank Boss
```
Create a 96x96 pixel art sprite of a massive stone golem boss, viewed from top-down perspective, facing upward. The golem should be heavily armored with rocky texture, glowing red eyes, and intimidating presence. Use a 20-color palette with gray, brown, and red accents. Transparent background, PNG format. Single sprite, no animation frames. Make it look like a final boss that takes many hits.
```

### Sniper Boss
```
Create an 80x80 pixel art sprite of a dark archer boss, viewed from top-down perspective, facing upward. The archer should hold a glowing magical bow, wear a dark hooded cloak, and have a mysterious presence. Use a 20-color palette with dark purple, black, and cyan accents. Transparent background, PNG format. Single sprite, no animation frames. Make it look like a ranged boss enemy.
```

### Swarm Boss
```
Create an 88x88 pixel art sprite of a necromancer boss surrounded by swirling dark energy and small skulls, viewed from top-down perspective, facing upward. The necromancer should wear dark robes and hold a staff. Use a 20-color palette with dark green, black, and white accents. Transparent background, PNG format. Single sprite, no animation frames. Make it look like a boss that summons minions.
```

## 📊 ボス仕様

| ボス | サイズ | シートサイズ | フレーム数 | FPS | 特徴 |
|------|--------|------------|-----------|-----|------|
| Tank | 96×96  | 576×96     | 6         | 6   | 高HP、広範囲攻撃 |
| Sniper | 80×80 | 480×80    | 6         | 8   | 遠距離攻撃、高精度 |
| Swarm | 88×88 | 528×88     | 6         | 10  | 敵召喚、群れ戦術 |

**共通仕様**:
- 同時表示1体のみ
- 上向き固定、rotation使用
- loop再生
- 最大テクスチャ1024×1024

## 📚 参考資料

- [docs/asset-specifications.md](../../../docs/asset-specifications.md#3-boss) - 詳細仕様
- [docs/dalle-prompts.md](../../../docs/dalle-prompts.md#3-boss) - プロンプト全文
