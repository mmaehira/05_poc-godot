# Characters Assets

キャラクター（プレイヤー、敵、ボス）のスプライトを配置するディレクトリです。

## 📖 詳細仕様

👉 **[docs/asset-specifications.md](../../docs/asset-specifications.md)** の「1. オブジェクト一覧と詳細仕様」を参照

## 📁 サブディレクトリ

- `player/` - プレイヤーキャラクター（48×48px）
- `enemies/` - 通常敵4種（28×28px 〜 56×56px）
- `bosses/` - ボス3種（80×80px 〜 96×96px）

## 🎨 必要なアセット

### Player
- [ ] `player_idle_48x48_4f.png` (192×48、8FPS、loop)
- [ ] `player_walk_48x48_4f.png` (192×48、12FPS、loop)
- [ ] `player_hit_48x48_2f.png` (96×48、15FPS、one-shot)
- [ ] `player_frames.tres` (SpriteFrames)

### Enemies
- [ ] `basic_enemy_idle_32x32_4f.png`
- [ ] `strong_enemy_idle_40x40_4f.png`
- [ ] `fast_enemy_idle_28x28_4f.png`
- [ ] `heavy_enemy_idle_56x56_4f.png`
- [ ] 各敵の `{type}_frames.tres`

### Bosses
- [ ] `tank_boss_idle_96x96_6f.png`
- [ ] `sniper_boss_idle_80x80_6f.png`
- [ ] `swarm_boss_idle_88x88_6f.png`
- [ ] 各ボスの `{type}_frames.tres`

## 🔧 重要な仕様

- **向き**: 上向きのみ作成、Godot側でrotation使用
- **フォーマット**: PNG（RGB+Alpha）
- **アニメーション**: idleモーションのみ（歩行アニメは不要）
- **背景**: 完全透過
