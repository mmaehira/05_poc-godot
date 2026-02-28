# Godot 4.3 - アセット作成ガイド

このガイドは、`docs/asset-specifications.md` の仕様に基づき、実際にアセットを作成する手順を初心者向けに解説します。

---

## 📚 目次

1. [クイックスタートガイド](#1-クイックスタートガイド)
2. [ピクセルアート作成の基本](#2-ピクセルアート作成の基本)
3. [プレイヤーキャラクター作成](#3-プレイヤーキャラクター作成)
4. [敵キャラクター作成](#4-敵キャラクター作成)
5. [エフェクト作成](#5-エフェクト作成)
6. [UI素材作成](#6-ui素材作成)
7. [音声素材作成](#7-音声素材作成)
8. [Godotへのインポート](#8-godotへのインポート)
9. [よくある失敗例と対処法](#9-よくある失敗例と対処法)
10. [品質チェックリスト](#10-品質チェックリスト)

---

## 1. クイックスタートガイド

### 5分でわかる本プロジェクトのアセット仕様

このプロジェクトは「2Dトップダウンアクションゲーム」です。Vampire Survivors風の見下ろし型ゲームで、以下の特徴があります：

- **基準サイズ**: 32px × 32px（タイル1マス）
- **プレイヤーサイズ**: 48px × 48px（タイル1.5マス）
- **向きの扱い**: **上向きのみ作成**（Godotが自動で回転させる）
- **描画スタイル**: ピクセルアート（ドット絵）
- **アニメ方式**: スプライトシート（横一列にフレームを並べる）

**つまり、キャラクターは上向きだけ描けばOKです！** 左右下向きは不要です。

### 必要なツール

| ツール | 用途 | 推奨ツール | 代替ツール |
|--------|------|-----------|----------|
| **ピクセルアートエディタ** | キャラ・エフェクト作成 | Aseprite（有料） | GIMP（無料）、LibreSprite（無料） |
| **音声編集ツール** | BGM/SE編集 | Audacity（無料） | - |
| **音声変換ツール** | OGG変換 | FFmpeg（無料） | Audacity内蔵変換 |

### アセット仕様書の読み方

本ガイドは実践的な手順を説明します。詳細な仕様は以下を参照してください：

- **完全仕様**: `docs/asset-specifications.md` - 全仕様の元データ
- **クイックリファレンス**: `assets/README.md` - 仕様サマリー
- **カテゴリ別仕様**: `assets/characters/README.md` など

---

## 2. ピクセルアート作成の基本

### 2.1 Asepriteのセットアップ

#### 新規ファイル作成

1. Asepriteを起動
2. `File` → `New...` を選択
3. 以下を設定：
   - **Width**: キャラサイズ（例：48px）
   - **Height**: キャラサイズ（例：48px）
   - **Color Mode**: RGBA（透過対応）
   - **Background**: Transparent（背景透過）
4. `OK` をクリック

#### グリッド設定（重要）

ピクセルアートでは1ピクセル単位で描くため、グリッドを表示します。

1. `View` → `Grid` → `Grid Settings...`
2. 以下を設定：
   - **Grid Size**: Width=1px、Height=1px
   - **Grid Color**: 好みの色（例：白）
3. `View` → `Grid` → `Show Grid` にチェック

#### ズーム設定

1. `View` → `Zoom` → `800%`（8倍）以上に設定
2. または、マウスホイールでズーム調整

### 2.2 パレット作成

ピクセルアートでは色数を制限して統一感を出します。

#### プロジェクト推奨パレット

以下の16色パレットを基準にしてください：

```
背景/アウトライン:
#000000（黒）、#1A1A1A（濃灰）、#2D2D2D（灰）、#FFFFFF（白）

プレイヤー/味方:
#4A90E2（青）、#7FCDCD（水色）、#357ABD（濃青）

敵:
#E74C3C（赤）、#C0392B（濃赤）、#FF6B6B（明赤）

アイテム:
#F39C12（橙）、#F1C40F（黄）、#2ECC71（緑）

エフェクト:
#9B59B6（紫）、#ECF0F1（白グレー）、#FFC300（明黄）
```

#### パレットの登録（Aseprite）

1. `Edit` → `Palette...`
2. 右下の `+` ボタンで色を追加
3. 上記の16進カラーコードを入力

### 2.3 描画の基本ルール

#### やるべきこと

- **アンチエイリアスOFF**: `Pencil Tool` を使用（`Brush Tool` は使わない）
- **1px単位で描画**: ズームして丁寧に
- **アウトライン必須**: キャラの輪郭を黒（#000000）で囲む
- **コントラスト重視**: 明暗の差をはっきりさせる

#### やってはいけないこと

- ぼかしツールを使う（ピクセルアートではNG）
- 自動補間を使う（手描きが基本）
- アウトラインを省略する（視認性が悪化）
- 半透明ピクセルを多用する（縁がぼやける）

---

## 3. プレイヤーキャラクター作成

### 3.1 仕様の確認

プレイヤーキャラクターは以下の3種類のアニメーションが必要です：

| モーション | ファイル名 | サイズ | フレーム数 | FPS | ループ |
|-----------|-----------|--------|----------|-----|--------|
| **待機** | player_idle_48x48_4f.png | 192×48 | 4 | 8 | loop |
| **移動** | player_walk_48x48_4f.png | 192×48 | 4 | 12 | loop |
| **被弾** | player_hit_48x48_2f.png | 96×48 | 2 | 15 | one-shot |

**重要**: 上向きのみ作成してください。左右下向きは不要です。

### 3.2 player_idle（待機アニメ）の作成

#### Step 1: キャンバス作成

1. Aseprite起動
2. `File` → `New...`
3. 以下を設定：
   - **Width**: 192px（48px × 4フレーム）
   - **Height**: 48px
   - **Color Mode**: RGBA
   - **Background**: Transparent
4. `OK` をクリック

#### Step 2: グリッドとガイド設定

1. `View` → `Grid` → `Grid Settings...`
   - **Grid Size**: Width=48px、Height=48px（1フレーム単位）
2. `View` → `Show` → `Grid`
3. `View` → `Show` → `Slice Bounds`（スライス境界表示）

#### Step 3: フレーム1を描画

**アウトラインから描く**

1. **Pencil Tool**（ショートカット: `B`）を選択
2. 色を黒（#000000）に設定
3. 以下のイメージで描画：

```
キャラクターの上半身（上向き）：
- 頭部: 中央上部に円形（約16×16px）
- 胴体: 頭の下に長方形（約20×24px）
- 腕: 胴体の両脇に小さく（各4×12px）
- 目: 頭部中央に2点（上向きなので正面顔）
```

**例（ASCIIアート風イメージ）：**

```
    ████
   ██..██     ← 頭（黒アウトライン+目）
   ██████
  ████████    ← 胴体（青系で塗る）
  ████████
 ██████████   ← 腕（両脇に配置）
  ████████
   ██████     ← 下半身
```

#### Step 4: 塗りつぶし

1. **Paint Bucket Tool**（ショートカット: `G`）を選択
2. プレイヤーカラー（#4A90E2）を選択
3. アウトライン内を塗りつぶす
4. 陰影をつける：
   - ハイライト: #7FCDCD（明るい部分）
   - シャドウ: #357ABD（暗い部分）

#### Step 5: フレーム2〜4を作成（待機アニメ）

待機アニメは「呼吸」を表現します。

1. **フレーム1を複製**:
   - `Frame` → `New Frame`（ショートカット: `Alt+N`）
2. **フレーム2**: 頭を1px上に移動（息を吸う）
3. **フレーム3**: 頭を元の位置に戻す
4. **フレーム4**: 頭を1px下に移動（息を吐く）

#### Step 6: アニメーションプレビュー

1. `View` → `Timeline` を表示
2. 再生ボタン（▶）でアニメ確認
3. FPS設定: タイムライン右上で `8 FPS` に設定

#### Step 7: エクスポート

1. `File` → `Export Sprite Sheet...`
2. 以下を設定：
   - **Sheet Type**: Horizontal Strip（横一列）
   - **Output File**: `player_idle_48x48_4f.png`
   - **Layers**: Merge（全レイヤー統合）
   - **Trim**: No（トリミングしない）
3. `Export` をクリック

### 3.3 player_walk（移動アニメ）の作成

#### Step 1: idleをベースにコピー

1. `player_idle_48x48_4f.png` を開く
2. `File` → `Save As...` → `player_walk_48x48_4f.png`

#### Step 2: 歩行アニメに変更

歩行は「足の動き」と「体の上下動」を表現します。

- **フレーム1**: 左足前、右足後、体が少し上
- **フレーム2**: 両足揃う、体が下
- **フレーム3**: 右足前、左足後、体が少し上
- **フレーム4**: 両足揃う、体が下

**具体的な変更点**:
- 下半身（足部分）を1-2px左右に動かす
- 全体を1px上下に動かす

#### Step 3: FPS設定とエクスポート

1. タイムラインで `12 FPS` に設定
2. 再生ボタンでアニメ確認（idleより速く動く）
3. `File` → `Export Sprite Sheet...` で保存

### 3.4 player_hit（被弾アニメ）の作成

#### Step 1: キャンバス作成

1. `File` → `New...`
   - **Width**: 96px（48px × 2フレーム）
   - **Height**: 48px
2. グリッド設定: 48px × 48px

#### Step 2: フレーム1（通常状態）

- `player_idle` のフレーム1をコピー

#### Step 3: フレーム2（点滅・赤色化）

被弾を表現するため、色を赤系に変更します。

1. **フレーム2を作成**
2. **色置換**:
   - `Edit` → `Replace Color...`
   - 青系（#4A90E2）→ 赤系（#E74C3C）に置換
3. **少し縮める**:
   - 全体を1px縮小（ダメージで縮む表現）

#### Step 4: FPS設定とエクスポート

1. タイムラインで `15 FPS` に設定
2. 再生ボタンで確認（素早く点滅）
3. エクスポート

### 3.5 向きの扱いの注意点

**本プロジェクトでは上向きのみ作成します。**

- 左向き、右向き、下向きは**作成不要**
- Godot側で `rotation` を使って自動回転させる
- これにより、4方向分（4倍）のフレーム数を削減できる

---

## 4. 敵キャラクター作成

### 4.1 仕様の確認

敵は4種類あります：

| 敵タイプ | ファイル名 | サイズ | フレーム数 | FPS |
|---------|-----------|--------|----------|-----|
| **Basic** | basic_enemy_idle_32x32_4f.png | 128×32 | 4 | 8 |
| **Strong** | strong_enemy_idle_40x40_4f.png | 160×40 | 4 | 8 |
| **Fast** | fast_enemy_idle_28x28_4f.png | 112×28 | 4 | 12 |
| **Heavy** | heavy_enemy_idle_56x56_4f.png | 224×56 | 4 | 6 |

### 4.2 Basic Enemy作成チュートリアル

#### Step 1: キャンバス作成

1. Aseprite起動
2. `File` → `New...`
   - **Width**: 128px（32px × 4フレーム）
   - **Height**: 32px
   - **Color Mode**: RGBA
   - **Background**: Transparent
3. グリッド設定: 32px × 32px

#### Step 2: デザイン方針

Basic Enemyは「雑魚敵」なので、シンプルなデザインにします。

**推奨デザイン**:
- 円形または楕円形のスライム風
- 色: 赤系（#E74C3C）
- 目: 2点（敵対的な印象）

**ASCIIイメージ**:

```
   ████
  ██..██   ← 赤い円形の敵（上向き）
  ██████
   ████
```

#### Step 3: フレーム1を描画

1. **アウトライン描画**:
   - 黒（#000000）で円形を描く
   - サイズ: 約24×24px（32pxキャンバスの中央）
2. **塗りつぶし**:
   - 赤系（#E74C3C）で塗る
3. **目を追加**:
   - 白い点2つ（各2×2px）

#### Step 4: フレーム2〜4を作成（脈動アニメ）

敵の待機アニメは「脈動」を表現します。

1. **フレーム2**: 全体を1px拡大（膨らむ）
2. **フレーム3**: 元のサイズに戻す
3. **フレーム4**: 全体を1px縮小（縮む）

**拡大・縮小の方法**:
- `Edit` → `Canvas Size...` で1px増減
- または `Transform Tool`（ショートカット: `Ctrl+T`）で手動調整

#### Step 5: エクスポート

1. タイムラインで `8 FPS` に設定
2. `File` → `Export Sprite Sheet...`
   - **Output File**: `basic_enemy_idle_32x32_4f.png`
3. `Export` をクリック

### 4.3 その他の敵キャラクター

#### Strong Enemy（強敵）

- **サイズ**: 40×40px（Basicより大きい）
- **色**: 濃い赤（#C0392B）
- **特徴**: アーマー風の装飾を追加（角、鎧パーツなど）

#### Fast Enemy（高速敵）

- **サイズ**: 28×28px（Basic より小さい）
- **色**: 明るい赤（#FF6B6B）
- **特徴**: 細長いシルエット、尾を追加（スピード感）

#### Heavy Enemy（重量級敵）

- **サイズ**: 56×56px（最大）
- **色**: 暗い赤（#C0392B）+ 灰色（#2D2D2D）
- **特徴**: ずっしりとした四角形、装甲パーツ

---

## 5. エフェクト作成

### 5.1 仕様の確認

エフェクトは以下の5種類が必要です：

| エフェクト | ファイル名 | サイズ | フレーム数 | FPS | ループ | 加算合成 |
|-----------|-----------|--------|----------|-----|--------|---------|
| **爆発** | explosion_effect_64x64_6f.png | 384×64 | 6 | 15 | one-shot | 有 |
| **銃口閃光** | muzzle_flash_effect_32x32_6f.png | 192×32 | 6 | 20 | one-shot | 有 |
| **レベルアップ** | level_up_effect_96x96_6f.png | 576×96 | 6 | 12 | one-shot | 有 |
| **被弾火花** | hit_spark_effect_24x24_4f.png | 96×24 | 4 | 18 | one-shot | 有 |
| **パワーアップオーラ** | powerup_aura_effect_64x64_4f.png | 256×64 | 4 | 8 | loop | 有 |

### 5.2 Explosion（爆発）作成チュートリアル

#### Step 1: キャンバス作成

1. Aseprite起動
2. `File` → `New...`
   - **Width**: 384px（64px × 6フレーム）
   - **Height**: 64px
3. グリッド設定: 64px × 64px

#### Step 2: フレーム1（発火開始）

爆発は中心から外側に広がります。

1. **中心点を描く**:
   - 明黄（#FFC300）で中心に小さな円（8×8px）
2. **ハイライト追加**:
   - 白（#FFFFFF）で中心に2-3ピクセル

#### Step 3: フレーム2（拡大開始）

1. **円を拡大**:
   - 黄色（#F1C40F）で16×16pxに拡大
2. **外縁を追加**:
   - 橙（#F39C12）で縁取り

#### Step 4: フレーム3（最大サイズ）

1. **さらに拡大**:
   - 黄色部分を32×32pxに拡大
2. **外側を赤く**:
   - 赤（#E74C3C）で外縁を囲む
3. **不規則な形に**:
   - 円形から不規則な形に変形（炎の揺らぎ）

#### Step 5: フレーム4〜6（消失）

1. **フレーム4**: 色を暗く（濃赤 #C0392B）、サイズ維持
2. **フレーム5**: さらに暗く、サイズ縮小（24×24px）
3. **フレーム6**: 灰色（#2D2D2D）、さらに縮小（16×16px）

#### Step 6: エクスポート

1. タイムラインで `15 FPS` に設定
2. エクスポート（`explosion_effect_64x64_6f.png`）

### 5.3 加算合成について

エフェクトは **加算合成（Additive Blending）** を使うことで、光っているように見えます。

**Godot側での設定**:
```gdscript
# エフェクトのAnimatedSprite2Dに設定
$ExplosionEffect.material = CanvasItemMaterial.new()
$ExplosionEffect.material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
```

**アセット作成時の注意点**:
- 黒い背景を避ける（完全透過にする）
- 明るい色（黄、白、明赤）を中心に使う
- 半透明ピクセルを活用して柔らかい光に

---

## 6. UI素材作成

### 6.1 仕様の確認

UI素材は以下のカテゴリがあります：

| カテゴリ | 素材例 | 9-slice対応 |
|---------|-------|-----------|
| **ボタン** | 小/中/大（128×48 〜 256×80） | 必須 |
| **パネル** | 小/中/大（256×192 〜 768×576） | 必須 |
| **ゲージ** | HP/EXP/ボスHP | 必須 |
| **アイコン** | 武器・スキルアイコン（64×64） | 不要 |

### 6.2 9-sliceとは？

**9-slice（ナインスライス）** は、UI素材を拡大縮小しても角が潰れない技術です。

**原理**:
画像を9つの領域に分割し、角と辺は固定サイズ、中央のみ伸縮させます。

```
┌───┬───────┬───┐
│ 1 │   2   │ 3 │  ← 1,3,7,9は固定（角）
├───┼───────┼───┤
│ 4 │   5   │ 6 │  ← 2,4,6,8は1方向に伸縮（辺）
├───┼───────┼───┤
│ 7 │   8   │ 9 │  ← 5は全方向に伸縮（中央）
└───┴───────┴───┘
```

### 6.3 ボタン（中）作成チュートリアル

#### Step 1: キャンバス作成

1. **GIMP**を起動（Asepriteより適している）
2. `File` → `New...`
   - **Width**: 192px
   - **Height**: 64px
   - **Fill with**: Transparency

#### Step 2: 9-sliceマージンを決める

仕様書によると、ボタン（中）のマージンは **12px** です。

**マージン図**:

```
←12px→                    ←12px→
┌────┬──────────────────┬────┐ ↑
│    │                  │    │ 12px
├────┼──────────────────┼────┤ ↓
│    │                  │    │
│    │   中央（伸縮）    │    │
│    │                  │    │
├────┼──────────────────┼────┤ ↑
│    │                  │    │ 12px
└────┴──────────────────┴────┘ ↓
  固定     横に伸縮        固定
```

#### Step 3: ベース背景を描く

1. **角丸長方形ツール**を選択
2. 色: 青系（#4A90E2）
3. 192×64pxの長方形を描く
4. **Filters** → **Decor** → **Round Corners**（角丸化）
   - Radius: 8px

#### Step 4: ハイライト・シャドウを追加

1. **上部にハイライト**:
   - 白（#FFFFFF、50%透過）で上部12pxに薄い線
2. **下部にシャドウ**:
   - 黒（#000000、30%透過）で下部12pxに薄い影

#### Step 5: エクスポート

1. `File` → `Export As...`
   - **ファイル名**: `button_medium_192x64.png`
   - **Format**: PNG
2. エクスポート設定:
   - **Save background color**: OFF
   - **Save resolution**: OFF

### 6.4 Godot側での9-slice設定

UIボタンに適用する手順：

1. Godotエディタで `Button` ノードを選択
2. `Inspector` → `Theme Overrides` → `Styles` → `Normal`
3. `StyleBoxTexture` を新規作成
4. `Texture` に `button_medium_192x64.png` を設定
5. `Region Rect` を設定:
   - **x**: 0
   - **y**: 0
   - **w**: 192
   - **h**: 64
6. **Margin** を設定（重要！）:
   - **Left**: 12
   - **Right**: 12
   - **Top**: 12
   - **Bottom**: 12
7. `Axis Stretch` → **Horizontal**: Tile、**Vertical**: Tile

これで、ボタンを横に伸ばしても角が潰れません。

### 6.5 HPゲージ作成チュートリアル

#### 背景（bg）

1. **サイズ**: 256×32px
2. **色**: 暗い灰色（#1A1A1A）
3. **枠**: 黒（#000000）で2px枠線
4. **9-sliceマージン**: 横8px、縦4px

#### 前景（fg）

1. **サイズ**: 248×24px（背景より小さい）
2. **色**: グラデーション
   - 左: 明るい緑（#2ECC71）
   - 右: 暗い緑（#27AE60）
3. **9-sliceマージン**: 横4px、縦4px

**Godot側での使用**:
- `TextureProgressBar` ノードを使用
- `Texture Under` に背景を設定
- `Texture Progress` に前景を設定
- `Nine Patch Stretch` を有効化

---

## 7. 音声素材作成

### 7.1 仕様の確認

| 種類 | フォーマット | サンプルレート | ビットレート | チャンネル | ループ |
|------|------------|--------------|------------|----------|--------|
| **BGM** | OGG Vorbis | 44100Hz | 128kbps | Stereo | 有 |
| **SE** | OGG Vorbis | 44100Hz | 96kbps | Mono | 無 |

### 7.2 BGM作成チュートリアル

#### Step 1: Audacityで音楽を編集

1. **Audacity**を起動
2. 既存の音楽ファイルをインポート:
   - `File` → `Open...` → WAVまたはMP3を選択
3. **ループポイントを決める**:
   - 開始: イントロ終了後（例：5秒地点）
   - 終了: 曲の終わり（例：65秒地点）

#### Step 2: トリミングと音量調整

1. **不要部分をカット**:
   - 選択ツールでドラッグ → `Edit` → `Delete`
2. **音量正規化**:
   - `Effect` → `Normalize...`
   - **Normalize peak amplitude to**: -1.0 dB

#### Step 3: OGGエクスポート

1. `File` → `Export` → `Export as OGG`
2. 設定:
   - **Quality**: 5（128kbps相当）
   - **Channel**: Stereo
3. **ファイル名**: `bgm_gameplay_140.ogg`（BPM含む）
4. `Save` をクリック

#### Step 4: ループポイント設定（重要！）

Godot側でループさせるため、メタデータを追加します。

**方法1: Godotエディタで設定**

1. Godotで `.ogg` ファイルをダブルクリック
2. `Import` タブで以下を設定:
   - **Loop**: ON
   - **Loop Offset**: ループ開始位置（秒単位）
   - 例：イントロが5秒なら `5.0`
3. `Reimport` をクリック

**方法2: vorbis-tools で設定**

```bash
# vorbiscommentコマンドでメタデータ追加
vorbiscomment -w bgm_gameplay_140.ogg -t "LOOPSTART=220500" -t "LOOPLENGTH=2205000"
```

- `LOOPSTART`: ループ開始サンプル数（44100Hz × 秒数）
- `LOOPLENGTH`: ループ区間のサンプル数

### 7.3 SE作成チュートリアル

#### Step 1: 短い効果音を作成/編集

1. Audacity起動
2. 効果音を録音またはインポート
3. **モノラルに変換**:
   - `Tracks` → `Mix` → `Mix Stereo Down to Mono`

#### Step 2: トリミング

1. 不要な無音部分を削除
2. 長さ: 0.1〜2秒が目安
   - 射撃音: 0.2〜0.5秒
   - 爆発音: 0.5〜1.5秒
   - UIクリック音: 0.1秒

#### Step 3: OGGエクスポート

1. `File` → `Export` → `Export as OGG`
2. 設定:
   - **Quality**: 3（96kbps相当）
   - **Channel**: Mono
3. **ファイル名**: `se_shoot_01.ogg`
4. `Save` をクリック

#### Step 4: バリエーション作成

同じ効果音を3種類作ると、ランダム再生で単調さを回避できます。

**バリエーションの作り方**:
- ピッチを少し変える（`Effect` → `Change Pitch...` → ±5%）
- 音量を少し変える（±3dB）
- リバーブを微調整

**ファイル名例**:
- `se_shoot_01.ogg`
- `se_shoot_02.ogg`
- `se_shoot_03.ogg`

---

## 8. Godotへのインポート

### 8.1 プロジェクト構造の確認

アセットは以下のディレクトリに配置します：

```
res://assets/
├── characters/
│   ├── player/
│   │   ├── player_idle_48x48_4f.png
│   │   ├── player_walk_48x48_4f.png
│   │   ├── player_hit_48x48_2f.png
│   │   └── player_frames.tres（後で作成）
│   └── enemies/
│       └── basic_enemy_idle_32x32_4f.png
├── ui/
│   └── buttons/
│       └── button_medium_192x64.png
└── audio/
    ├── bgm/
    │   └── bgm_gameplay_140.ogg
    └── se/
        └── se_shoot_01.ogg
```

### 8.2 画像ファイルのインポート

#### Step 1: ファイルをコピー

1. エクスプローラー（Windows）/ Finder（Mac）で、作成したPNGファイルを開く
2. Godotエディタの `FileSystem` パネルにドラッグ&ドロップ
3. 該当ディレクトリに配置（例：`res://assets/characters/player/`）

#### Step 2: インポート設定を変更

Godotは自動でインポートしますが、ピクセルアートに適した設定に変更します。

1. `FileSystem` パネルで `.png` ファイルをクリック
2. `Import` タブ（右側）を開く
3. **以下を設定**:

**ピクセルアート（キャラ・エフェクト）**

```
Compress:
  Mode: VRAM Compressed
Mipmaps:
  Generate: false
Process:
  Fix Alpha Border: true
  Premult Alpha: false
```

**UI素材**

```
Compress:
  Mode: Lossy
Mipmaps:
  Generate: false
Process:
  Fix Alpha Border: true
```

4. **Reimport** ボタンをクリック（重要！）

### 8.3 SpriteFrames作成（アニメーション設定）

#### Step 1: AnimatedSprite2Dノードを作成

1. `Scene` パネルで `+` ボタン → `AnimatedSprite2D` を検索
2. ノード名を `Player` に変更

#### Step 2: SpriteFramesリソースを作成

1. `Inspector` パネルで `Sprite Frames` プロパティを見つける
2. `<empty>` をクリック → `New SpriteFrames` を選択
3. `SpriteFrames` をクリックして、下部に `SpriteFrames` パネルが表示される

#### Step 3: アニメーションを追加

1. `SpriteFrames` パネルで `default` アニメを削除（右クリック → Delete）
2. `Add Animation` ボタン（+）をクリック
3. アニメーション名を `idle` に変更

#### Step 4: フレームを追加

1. `idle` アニメを選択した状態で、`Add Frames from Sprite Sheet` ボタンをクリック
2. `player_idle_48x48_4f.png` を選択
3. **Horizontal** と **Vertical** を設定:
   - **Horizontal**: 4（フレーム数）
   - **Vertical**: 1
4. 全てのフレームを選択（Shift+クリック）
5. `Add 4 Frame(s)` をクリック

#### Step 5: FPS設定

1. `SpriteFrames` パネル右上の `Speed (FPS)` を設定
2. `idle` アニメの場合: **8 FPS**

#### Step 6: 他のアニメーションも追加

同様に `walk`（12 FPS）、`hit`（15 FPS）を追加します。

#### Step 7: SpriteFramesを保存

1. `Inspector` パネルで `Sprite Frames` プロパティの右側の `▼` をクリック
2. `Save` を選択
3. **保存先**: `res://assets/characters/player/player_frames.tres`

### 8.4 音声ファイルのインポート

#### Step 1: ファイルをコピー

1. `.ogg` ファイルを `FileSystem` パネルにドラッグ&ドロップ
2. `res://assets/audio/bgm/` または `res://assets/audio/se/` に配置

#### Step 2: BGMのループ設定

1. BGMファイル（例：`bgm_gameplay_140.ogg`）をクリック
2. `Import` タブで以下を設定:
   - **Loop**: ON
   - **Loop Offset**: イントロの長さ（秒単位、例：5.0）
3. `Reimport` をクリック

#### Step 3: SEはそのまま使用

SEはループ不要なので、デフォルト設定でOKです。

---

## 9. よくある失敗例と対処法

### 9.1 スプライトがぼやける

**症状**: ピクセルアートがぼやけて表示される

**原因**: Filter設定が `Linear` になっている

**対処法**:
1. `Project` → `Project Settings...` を開く
2. `Rendering` → `Textures` → `Canvas Textures`
3. **Default Texture Filter** を `Nearest` に変更
4. または、各テクスチャの `Import` タブで `Filter` を `false` に設定

### 9.2 スプライトが1ピクセルずれる

**症状**: キャラクターが移動すると、1pxずつブレる

**原因**: Pixel Snapが無効

**対処法**:
1. `Project` → `Project Settings...` → `Rendering` → `2D` → `Snapping`
2. **Use Gpu Pixel Snap** を `true` に変更
3. **Transform Snap** も有効化

### 9.3 アニメーションが再生されない

**症状**: AnimatedSprite2Dが静止画のまま

**原因1**: アニメーションが再生されていない

**対処法**:
```gdscript
# _ready()でアニメーション再生
$AnimatedSprite2D.play("idle")
```

**原因2**: FPSが0になっている

**対処法**:
- `SpriteFrames` パネルで `Speed (FPS)` を確認（8以上に設定）

### 9.4 9-sliceが機能しない

**症状**: ボタンを拡大すると、角が潰れる

**原因**: Marginが設定されていない

**対処法**:
1. `StyleBoxTexture` の `Inspector` で `Margin` を確認
2. 仕様書通りのマージンを設定（例：ボタン中は12px）

### 9.5 BGMがループしない

**症状**: BGMが1回再生されて終了

**原因**: Loop設定がOFFになっている

**対処法**:
1. `.ogg` ファイルの `Import` タブで `Loop` を `ON` に設定
2. `Reimport` をクリック
3. または、GDScriptで手動設定:

```gdscript
var bgm = load("res://assets/audio/bgm/bgm_gameplay_140.ogg")
$AudioStreamPlayer.stream = bgm
$AudioStreamPlayer.stream.loop = true
$AudioStreamPlayer.play()
```

### 9.6 エクスポートしたスプライトシートのサイズが違う

**症状**: 192×48pxのはずが、別のサイズになっている

**原因**: Export時に `Trim` が有効になっている

**対処法**:
1. Asepriteで `File` → `Export Sprite Sheet...`
2. `Trim Cels` のチェックを **外す**
3. `Padding` も `0` に設定

### 9.7 透過部分が黒くなる

**症状**: キャラの周りに黒い縁ができる

**原因**: アンチエイリアスが有効、または `Premult Alpha` が ON

**対処法**:
1. Asepriteで `Pencil Tool` を使う（`Brush Tool` は使わない）
2. Godotの `Import` タブで `Premult Alpha` を `false` に設定

### 9.8 同時に大量のSEが鳴ると音が途切れる

**症状**: 敵を大量に倒すと、効果音が鳴らなくなる

**原因**: AudioServerのバス数上限（デフォルト32音）

**対処法**:
```gdscript
# _ready()で最大バス数を増やす
AudioServer.set_bus_count(64)
```

**または**: 優先度の低いSEを間引く（距離が遠い敵の音を鳴らさない）

---

## 10. 品質チェックリスト

アセットをプロジェクトに追加する前に、以下を確認してください。

### 10.1 画像アセット（共通）

- [ ] ファイル名が仕様書通り（`{type}_{motion}_{size}_{frames}f.png`）
- [ ] フォーマットがPNG（RGB+Alpha）
- [ ] 背景が完全透過（黒背景になっていない）
- [ ] サイズが仕様書通り（例：player_idle = 192×48px）
- [ ] アンチエイリアスが無効（ピクセルがぼやけていない）
- [ ] アウトラインが明確（黒縁で囲まれている）

### 10.2 スプライトシート

- [ ] フレームが横一列に並んでいる（縦に並んでいない）
- [ ] フレーム間に余白がない（0px）
- [ ] 各フレームが同じサイズ
- [ ] トリミングされていない（Trim=無効）

### 10.3 キャラクター

- [ ] 上向きのみ作成（左右下向きは不要）
- [ ] アニメーションがスムーズ（Asepriteで再生確認済み）
- [ ] FPS設定が仕様書通り（idle=8、walk=12、hit=15）
- [ ] ループ設定が適切（idle/walk=loop、hit=one-shot）
- [ ] 視認性が良い（小さくても見える）

### 10.4 UI素材

- [ ] 9-slice対応素材のマージンが適切
- [ ] 角丸やグラデーションが美しい
- [ ] 拡大しても崩れないデザイン
- [ ] コントラストが高い（背景と区別しやすい）

### 10.5 音声アセット

#### BGM

- [ ] フォーマットがOGG Vorbis
- [ ] サンプルレートが44100Hz
- [ ] チャンネルがStereo
- [ ] ループポイントが設定されている
- [ ] 音量が適切（-1.0 dB正規化済み）
- [ ] イントロ→ループ→終了が自然に繋がる

#### SE

- [ ] フォーマットがOGG Vorbis
- [ ] サンプルレートが44100Hz
- [ ] チャンネルがMono
- [ ] 長さが0.1〜2秒
- [ ] 音量が適切（他のSEと同じレベル）
- [ ] 不要な無音部分がない

### 10.6 Godotインポート

- [ ] インポート設定が仕様書通り（Compress、Mipmaps、Filter）
- [ ] SpriteFramesが正しく作成されている
- [ ] アニメーションが再生される
- [ ] Pixel Snapが有効（ブレない）
- [ ] BGMがループする
- [ ] SEが正常に再生される

### 10.7 ファイル配置

- [ ] ファイルが正しいディレクトリに配置されている
- [ ] 命名規則が統一されている
- [ ] 不要なファイルがない（.aseprite元ファイルは別管理）

---

## 参考リンク

### 公式ドキュメント

- **Godot 4.3 公式ドキュメント**: https://docs.godotengine.org/en/stable/
- **AnimatedSprite2D**: https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html
- **SpriteFrames**: https://docs.godotengine.org/en/stable/classes/class_spriteframes.html
- **StyleBoxTexture（9-slice）**: https://docs.godotengine.org/en/stable/classes/class_styleboxe texture.html

### ツールダウンロード

- **Aseprite**: https://www.aseprite.org/（有料）
- **LibreSprite**: https://libresprite.github.io/（無料、Asepriteフォーク）
- **GIMP**: https://www.gimp.org/（無料）
- **Audacity**: https://www.audacityteam.org/（無料）
- **FFmpeg**: https://ffmpeg.org/（無料）

### 学習リソース

- **ピクセルアートチュートリアル**: https://lospec.com/pixel-art-tutorials
- **パレット集**: https://lospec.com/palette-list
- **フリーSE素材**: https://freesound.org/

---

## まとめ

このガイドに従えば、初心者でも以下のアセットを作成できます：

1. **キャラクター**: 上向きのみのピクセルアート、4-6フレームアニメ
2. **エフェクト**: 加算合成対応の爆発・光エフェクト
3. **UI素材**: 9-slice対応の伸縮可能なボタン・パネル
4. **音声**: OGG形式のBGM（ループ対応）とSE

**重要なポイント**:
- **上向きのみ作成**（左右下向きは不要）
- **Pixel Snap有効化**（ブレ防止）
- **9-sliceマージン設定**（UI伸縮対応）
- **OGGループ設定**（BGM用）

詳細な仕様は `docs/asset-specifications.md` を、配置ルールは `assets/README.md` を参照してください。

**質問・トラブル時の確認順序**:
1. 本ガイドの「よくある失敗例」を確認
2. `docs/asset-specifications.md` で仕様を再確認
3. 品質チェックリストで漏れがないかチェック

それでは、素晴らしいアセットを作成してください！
