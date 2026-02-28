# DALL-E 3プロンプト集 - Godot 2Dゲームアセット

このドキュメントは、ChatGPT Plus（DALL-E 3）を使用してゲームアセットを生成するための最適化されたプロンプト集です。

## 📋 使用方法

1. **カテゴリを選択**: 必要なアセットのカテゴリを選択
2. **プロンプトをコピー**: 該当するプロンプトをコピー
3. **ChatGPTに入力**: ChatGPT Plusでプロンプトを送信
4. **画像を保存**: 生成された画像をダウンロード
5. **指定の場所に配置**: `assets/` ディレクトリの該当フォルダに保存

## ⚠️ 重要な注意事項

### DALL-E 3の制約
- **スプライトシート生成は困難**: DALL-E 3は複数フレームを正確に横並びで生成することが苦手です
- **推奨アプローチ**: 単一フレームを生成し、外部ツール（Aseprite/Piskel）でスプライトシート化
- **または**: プレースホルダーとして使用し、後でアーティストが修正

### プロンプト最適化のコツ
- **"pixel art"** を必ず含める
- **サイズを明示** (例: "48x48 pixels")
- **"transparent background"** を必ず含める
- **"top-down view"** を必ず含める（トップダウンゲーム用）
- **"single sprite"** を指定して1フレームのみ生成
- **色を制限** (例: "16-color palette")

---

## 🎮 キャラクター素材

### 1. Player（プレイヤー）

#### Player Idle（待機）- 1フレーム
```
Create a 48x48 pixel art sprite of a fantasy warrior character in idle pose, viewed from top-down perspective. The character should be facing upward. Use a vibrant 16-color palette with a blue and silver color scheme. The sprite should have a clear silhouette with sharp, clean pixel art style. Transparent background, PNG format. Single sprite, no animation frames. Make it suitable for a vampire survivors-style game.
```

#### Player Walk（移動）- 1フレーム
```
Create a 48x48 pixel art sprite of a fantasy warrior character in walking pose, viewed from top-down perspective. The character should be facing upward, with one leg forward suggesting forward movement. Use a vibrant 16-color palette with a blue and silver color scheme. The sprite should have a clear silhouette with sharp, clean pixel art style. Transparent background, PNG format. Single sprite, no animation frames.
```

#### Player Hit（被弾）- 1フレーム
```
Create a 48x48 pixel art sprite of a fantasy warrior character in hit/damage pose, viewed from top-down perspective. The character should be facing upward, with a recoiling motion. Add a slight red flash effect. Use a vibrant 16-color palette with a blue and silver color scheme. Transparent background, PNG format. Single sprite, no animation frames.
```

**配置先**: `assets/characters/player/`

**後処理が必要**:
- idle: 4フレーム分を手動複製して `player_idle_48x48_4f.png` (192×48)
- walk: 4フレーム分をAseprite等でアニメーション化
- hit: 2フレーム分を作成

---

### 2. Enemy（敵キャラクター）

#### Basic Enemy（基本敵）
```
Create a 32x32 pixel art sprite of a small slime monster, viewed from top-down perspective, facing upward. The slime should be green with a simple cute design. Use a 12-color palette. Transparent background, PNG format. Single sprite, no animation frames. Make it suitable for a vampire survivors-style enemy that appears in large numbers.
```

#### Strong Enemy（強敵）
```
Create a 40x40 pixel art sprite of a skeleton warrior, viewed from top-down perspective, facing upward. The skeleton should hold a sword and shield, with white bones and dark armor accents. Use a 16-color palette. Transparent background, PNG format. Single sprite, no animation frames. Make it look tougher than basic enemies.
```

#### Fast Enemy（高速敵）
```
Create a 28x28 pixel art sprite of a small bat creature, viewed from top-down perspective, facing upward. The bat should have spread wings suggesting fast movement, with purple and black colors. Use a 12-color palette. Transparent background, PNG format. Single sprite, no animation frames. Make it look agile and fast.
```

#### Heavy Enemy（重量敵）
```
Create a 56x56 pixel art sprite of a large orc warrior, viewed from top-down perspective, facing upward. The orc should be bulky and intimidating, with green skin and heavy armor. Use a 16-color palette. Transparent background, PNG format. Single sprite, no animation frames. Make it look slow but powerful.
```

**配置先**: `assets/characters/enemies/`

**後処理が必要**:
- 各敵タイプ: 4フレーム分のアニメーションを作成して横並びのスプライトシートに

---

### 3. Boss（ボス敵）

#### Tank Boss（戦車型ボス）
```
Create a 96x96 pixel art sprite of a massive stone golem boss, viewed from top-down perspective, facing upward. The golem should be heavily armored with rocky texture, glowing red eyes, and intimidating presence. Use a 20-color palette with gray, brown, and red accents. Transparent background, PNG format. Single sprite, no animation frames. Make it look like a final boss that takes many hits.
```

#### Sniper Boss（狙撃型ボス）
```
Create an 80x80 pixel art sprite of a dark archer boss, viewed from top-down perspective, facing upward. The archer should hold a glowing magical bow, wear a dark hooded cloak, and have a mysterious presence. Use a 20-color palette with dark purple, black, and cyan accents. Transparent background, PNG format. Single sprite, no animation frames. Make it look like a ranged boss enemy.
```

#### Swarm Boss（群れ型ボス）
```
Create an 88x88 pixel art sprite of a necromancer boss surrounded by swirling dark energy and small skulls, viewed from top-down perspective, facing upward. The necromancer should wear dark robes and hold a staff. Use a 20-color palette with dark green, black, and white accents. Transparent background, PNG format. Single sprite, no animation frames. Make it look like a boss that summons minions.
```

**配置先**: `assets/characters/bosses/`

**後処理が必要**:
- 各ボス: 6フレーム分のアニメーションを作成

---

## 🔫 武器・発射物

### Straight Shot Projectile（直線弾）
```
Create a 16x16 pixel art sprite of a simple energy projectile, viewed from top-down perspective, pointing upward. The projectile should be a glowing blue/cyan energy orb or bolt. Use an 8-color palette. Transparent background, PNG format. Single sprite, suitable for rapid-fire weapon.
```

### Area Blast Projectile（範囲攻撃弾）
```
Create a 24x24 pixel art sprite of an explosive fireball projectile, viewed from top-down perspective. The fireball should be orange and yellow with a swirling pattern. Use a 12-color palette. Transparent background, PNG format. Single sprite. Make it look like it will explode on impact.
```

### Homing Missile Projectile（追尾ミサイル）
```
Create a 20x20 pixel art sprite of a magical homing missile, viewed from top-down perspective, pointing upward. The missile should be purple with glowing trailing particles. Use a 12-color palette. Transparent background, PNG format. Single sprite. Make it look mystical and fast.
```

### Laser Beam Projectile（レーザー）
```
Create an 8x32 pixel art sprite of a thin laser beam, viewed from top-down perspective, vertical orientation. The laser should be bright cyan or red with a glowing core. Use a 6-color palette. Transparent background, PNG format. Single sprite, elongated vertical shape.
```

### Lightning Projectile（雷撃）
```
Create a 16x48 pixel art sprite of a lightning bolt, viewed from top-down perspective, vertical orientation. The lightning should be bright yellow/white with jagged edges. Use an 8-color palette. Transparent background, PNG format. Single sprite, make it look electric and dangerous.
```

### Orbital Projectile（周回弾）
```
Create a 20x20 pixel art sprite of a magical orb that orbits the player, viewed from top-down perspective. The orb should be glowing purple or blue with sparkle effects. Use a 10-color palette. Transparent background, PNG format. Single sprite. Make it look protective and magical.
```

**配置先**: `assets/weapons/projectiles/`

**後処理**: アニメーションが必要な弾丸は4フレーム分を作成

---

## 💎 アイテム

### EXP Orb Small（小経験値オーブ）
```
Create a 12x12 pixel art sprite of a small glowing experience orb, viewed from top-down perspective. The orb should be bright yellow or gold with a gentle glow. Use an 8-color palette. Transparent background, PNG format. Single sprite. Make it small and collectible.
```

### EXP Orb Medium（中経験値オーブ）
```
Create a 16x16 pixel art sprite of a medium glowing experience orb, viewed from top-down perspective. The orb should be bright green with a stronger glow than the small version. Use a 10-color palette. Transparent background, PNG format. Single sprite. Make it more valuable-looking than the small orb.
```

### EXP Orb Large（大経験値オーブ）
```
Create a 20x20 pixel art sprite of a large glowing experience orb, viewed from top-down perspective. The orb should be bright blue or cyan with the strongest glow. Use a 12-color palette. Transparent background, PNG format. Single sprite. Make it look very valuable and rare.
```

### Powerup Item（パワーアップアイテム）
```
Create a 24x24 pixel art sprite of a powerup item, viewed from top-down perspective. The item should be a glowing red crystal or potion bottle with sparkle effects. Use a 12-color palette. Transparent background, PNG format. Single sprite. Make it look powerful and temporary.
```

### Magnet Item（マグネットアイテム）
```
Create a 24x24 pixel art sprite of a magnet item, viewed from top-down perspective. The item should be a stylized magnet with magnetic field lines or sparkles around it. Use red, blue, and white colors. Use a 10-color palette. Transparent background, PNG format. Single sprite. Make it look like it attracts items.
```

**配置先**: `assets/items/`

**後処理**: 各アイテム4フレームのアニメーション（回転や輝き）を作成

---

## ✨ エフェクト

### Explosion Effect（爆発エフェクト）
```
Create a 64x64 pixel art sprite of an explosion effect, viewed from top-down perspective. The explosion should be circular with orange, yellow, and red colors radiating outward. Use a 16-color palette. Transparent background, PNG format. Single frame of an explosion animation. Make it dynamic and impactful.
```

### Muzzle Flash Effect（マズルフラッシュ）
```
Create a 32x32 pixel art sprite of a muzzle flash effect, viewed from top-down perspective. The flash should be bright yellow/white with a star-burst pattern. Use an 8-color palette. Transparent background, PNG format. Single frame. Make it look like a weapon firing effect.
```

### Level Up Effect（レベルアップエフェクト）
```
Create a 96x96 pixel art sprite of a level up effect, viewed from top-down perspective. The effect should be a radiant burst with golden light rays and sparkles. Use a 16-color palette with gold, yellow, and white. Transparent background, PNG format. Single frame. Make it celebratory and impressive.
```

### Hit Spark Effect（ヒットスパークエフェクト）
```
Create a 24x24 pixel art sprite of a hit spark effect, viewed from top-down perspective. The spark should be white/yellow with small radiating lines. Use an 8-color palette. Transparent background, PNG format. Single frame. Make it look like a quick impact flash.
```

### Powerup Aura Effect（パワーアップオーラ）
```
Create a 64x64 pixel art sprite of a circular aura effect, viewed from top-down perspective. The aura should be a glowing red or purple energy ring with particles. Use a 12-color palette. Transparent background, PNG format. Single frame. Make it look like it surrounds the player.
```

**配置先**: `assets/effects/`

**後処理**:
- Explosion: 6フレーム
- Muzzle Flash: 6フレーム
- Level Up: 6フレーム
- Hit Spark: 4フレーム
- Powerup Aura: 4フレーム（ループ）

---

## 🎨 UI素材

### Button（ボタン）
```
Create a 192x64 pixel art UI button with rounded corners and a medieval fantasy style. The button should have a stone or wood texture with a subtle 3D bevel effect. Use brown, gray, and gold colors. Include a slight shadow for depth. Transparent background, PNG format. Design should support 9-slice scaling.
```

### Panel（パネル）
```
Create a 512x384 pixel art UI panel with a medieval fantasy frame. The panel should have ornate corners with decorative elements, a stone or parchment texture background. Use brown, beige, and gold colors. Transparent background, PNG format. Design should support 9-slice scaling with 24px margins.
```

### HP Gauge Background（HPゲージ背景）
```
Create a 256x32 pixel art health gauge background bar, horizontal orientation. The bar should have a dark metal or stone frame with inner shadow. Use dark gray and black colors. Transparent background, PNG format. Design should support 9-slice horizontal scaling.
```

### HP Gauge Foreground（HPゲージ前景）
```
Create a 248x24 pixel art health gauge fill bar, horizontal orientation. The bar should be bright red gradient (dark red to bright red from left to right). Add a subtle shine or glass effect. Transparent background, PNG format. Design should support 9-slice horizontal scaling.
```

### Icon Frame（アイコン枠）
```
Create a 64x64 pixel art icon frame with a medieval fantasy style. The frame should have ornate borders with metal or stone texture. Use gold, bronze, and dark brown colors. Transparent center area for icon placement. PNG format. Make it suitable for weapon and skill icons.
```

**配置先**: `assets/ui/`

**注意**: UI素材は9-slice設定が必要なため、Godotで設定を行う必要があります

---

## 🌍 環境素材

### Ground Tile（地面タイル）
```
Create a 32x32 pixel art ground tile with grass texture, seamlessly tileable. The tile should have a simple grass pattern with occasional darker spots for variation. Use green, dark green, and brown colors. Use a 12-color palette. Transparent background NOT needed (opaque). PNG format. Make sure the edges are seamless for tiling.
```

### Wall Tile（壁タイル）
```
Create a 32x32 pixel art stone wall tile, seamlessly tileable. The tile should have a brick or stone block texture with mortar lines. Use gray, dark gray, and brown colors. Use a 10-color palette. Transparent background, PNG format. Make sure the edges are seamless for tiling. Top-down perspective showing the top surface of a wall.
```

### Decoration - Rock（岩の装飾）
```
Create a 48x48 pixel art large rock decoration, viewed from top-down perspective. The rock should have a natural stone texture with highlights and shadows. Use gray, brown, and dark gray colors. Use a 10-color palette. Transparent background, PNG format. Single sprite, suitable for placing on the game field.
```

### Decoration - Bush（茂みの装飾）
```
Create a 32x32 pixel art bush decoration, viewed from top-down perspective. The bush should be round and fluffy with leaves, bright green color. Use a 10-color palette. Transparent background, PNG format. Single sprite, suitable for placing on the game field as scenery.
```

**配置先**: `assets/environment/`

**後処理**: タイル素材は512×512のタイルセットシートに配置する必要があります

---

## 🎵 オーディオ素材の入手方法

DALL-E 3は画像のみ生成可能です。オーディオ素材は以下のオープンソースサイトから入手してください：

### BGM/SE推奨サイト
1. **OpenGameArt.org** - https://opengameart.org/
   - ライセンス: CC0, CC-BY多数
   - 検索: "action game music", "8bit sound effects"

2. **Freesound.org** - https://freesound.org/
   - ライセンス: CC0, CC-BY多数
   - 高品質なSE多数

3. **Incompetech** - https://incompetech.com/music/
   - Kevin MacLeod作曲、CC-BY
   - BGMに最適

4. **JFXR** - https://jfxr.frozenfractal.com/
   - ブラウザ上でレトロSE生成
   - 無料、商用利用可

**配置先**: `assets/audio/bgm/` および `assets/audio/se/`

**注意**: OGG形式に変換が必要（Audacityなど使用）

---

## 📝 ワークフロー例

### ステップ1: プレイヤーキャラクターを作成
1. 上記の "Player Idle" プロンプトをChatGPTに入力
2. 生成された画像をダウンロード: `player_idle_frame1.png`
3. 必要に応じて "Player Walk" と "Player Hit" も生成
4. `assets/characters/player/` に保存

### ステップ2: 後処理（Asepriteまたはオンラインツール）
1. Asepriteで新規ファイル作成: 192×48（4フレーム分）
2. 生成した1フレームを4回コピーして横並び配置
3. 微調整（色補正、ドット打ち直しなど）
4. エクスポート: `player_idle_48x48_4f.png`

### ステップ3: Godotにインポート
1. Godotプロジェクトを開く
2. `.godot/imported/` に自動インポートされる
3. インポート設定を確認（Filter: Nearest, Mipmaps: Off）

### ステップ4: SpriteFrames作成
1. AnimatedSprite2Dノードを作成
2. SpriteFramesリソースを新規作成
3. スプライトシートを追加、フレーム分割設定
4. `player_frames.tres` として保存

---

## 🔧 トラブルシューティング

### Q: DALL-E 3がスプライトシートを正確に生成できない
**A**: これは正常です。DALL-E 3は単一画像生成に最適化されています。
- 解決策1: 単一フレームを生成し、Asepriteで手動でスプライトシート化
- 解決策2: 複数の単一フレームを生成し、Pythonスクリプトで結合
- 解決策3: プレースホルダーとして使用し、後で専門アーティストに依頼

### Q: 生成された画像のサイズが指定と異なる
**A**: DALL-E 3は正確なピクセルサイズを保証しません。
- 解決策: 生成後、画像編集ソフトで正確なサイズにリサイズ
- ツール: Aseprite, GIMP, Photoshop, オンラインツール

### Q: 透過背景が正しく生成されない
**A**: プロンプトに "transparent background" を含めても失敗する場合があります。
- 解決策: 画像編集ソフトで背景を手動削除
- ツール: remove.bg（オンライン）, GIMP（マジックワンド）

### Q: ピクセルアートがぼやけている
**A**: DALL-E 3は高解像度画像を生成するため、ピクセルアートが滑らかになる場合があります。
- 解決策: Asepriteで再度ピクセル化、またはNearest Neighbor法でリサイズ

---

## 🎯 次のステップ

1. ✅ プロンプト集を確認
2. ⬜ ChatGPT Plusで必要なアセットを生成
3. ⬜ 生成された画像をダウンロード
4. ⬜ `assets/` ディレクトリに配置
5. ⬜ アセット検証スクリプトで確認
6. ⬜ Godotでインポート確認
7. ⬜ SpriteFrames作成
8. ⬜ ゲームに統合

---

**参考資料**:
- [docs/asset-specifications.md](asset-specifications.md) - 詳細な技術仕様
- [docs/asset-workflow.md](asset-workflow.md) - 全体ワークフロー
- [assets/README.md](../assets/README.md) - アセット配置ルール
