# Player Character Asset Creation Template

このテンプレートは、Godot 4.3プロジェクト用のプレイヤーキャラクター素材を作成するための完全ガイドです。

---

## 目次

1. [仕様サマリー](#1-仕様サマリー)
2. [デザイン指示とASCIIアート](#2-デザイン指示とasciiアート)
3. [色パレット定義](#3-色パレット定義)
4. [Asepriteプロジェクト設定](#4-asepriteプロジェクト設定)
5. [エクスポート手順](#5-エクスポート手順)
6. [Godot SpriteFrames作成手順](#6-godot-spriteframes作成手順)
7. [トラブルシューティング](#7-トラブルシューティング)

---

## 1. 仕様サマリー

### 基本仕様

| 項目 | 値 |
|------|-----|
| **1フレームサイズ** | 48×48 px |
| **向き** | 上向きのみ（回転はGodotで自動処理） |
| **フォーマット** | PNG（RGB+Alpha） |
| **背景** | 完全透過 |
| **総フレーム数** | 10フレーム（idle: 4、walk: 4、hit: 2） |

### モーション別仕様

| モーション | ファイル名 | シートサイズ | フレーム数 | FPS | ループ |
|-----------|-----------|------------|----------|-----|--------|
| **待機（idle）** | `player_idle_48x48_4f.png` | 192×48 px | 4 | 8 | loop |
| **移動（walk）** | `player_walk_48x48_4f.png` | 192×48 px | 4 | 12 | loop |
| **被弾（hit）** | `player_hit_48x48_2f.png` | 96×48 px | 2 | 15 | one-shot |

### 重要な注意点

- **上向きのみ作成**: 左右下向きは不要（Godotが`rotation`で自動回転）
- **アンチエイリアス禁止**: Pencilツールのみ使用（Brushツール禁止）
- **アウトライン必須**: 黒（#000000）で輪郭を囲む
- **1px精度**: ズーム800%以上で丁寧に描く

---

## 2. デザイン指示とASCIIアート

### 記号の意味

```
@ = 頭部
O = 胴体上部
0 = 胴体下部
- = 腕（横）
| = 脚（縦）
. = 目
# = アウトライン（黒）
空白 = 透過
```

### 2.1 player_idle（待機アニメーション）

**目的**: 呼吸による上下動を表現

#### Frame 1（基準姿勢）

```
    ####
   ##@@##
   #.@@.#
   ######
  ##OOOO##
  #OOOOOO#
 ##OOOOOO##
 #--OOOO--#
  ##0000##
   #0000#
   ##||##
    #||#
    ####
```

**ポーズ説明**:
- 頭: 中央上部、約16×16px
- 目: 2点、上向き正面顔
- 胴体: 頭の下、約20×28px
- 腕: 胴体の両脇、各4×12px
- 脚: 下部、約8×12px

#### Frame 2（息を吸う）

```
    ####      ← 頭全体を1px上に移動
   ##@@##
   #.@@.#
   ######
  ##OOOO##   ← 胴体は位置固定
  #OOOOOO#
 ##OOOOOO##
 #--OOOO--#
  ##0000##
   #0000#
   ##||##
    #||#
    ####
```

**変更点**: 頭部を1px上に移動

#### Frame 3（通常位置）

```
（Frame 1と同じ）
```

**変更点**: Frame 1に戻る

#### Frame 4（息を吐く）

```
    （頭が1px下）
    ####      ← 頭全体を1px下に移動
   ##@@##
   #.@@.#
   ######
  ##OOOO##
  #OOOOOO#
 ##OOOOOO##
 #--OOOO--#
  ##0000##
   #0000#
   ##||##
    #||#
    ####
```

**変更点**: 頭部を1px下に移動

---

### 2.2 player_walk（移動アニメーション）

**目的**: 浮遊しながら移動する表現（トップダウンビュー）

#### Frame 1（左足前）

```
    ####
   ##@@##
   #.@@.#
   ######
  ##OOOO##   ← 体全体を1px上に
  #OOOOOO#
 ##OOOOOO##
 #--OOOO--#
  ##0000##
   #0000#
   #||##     ← 左脚1px前（上）
    #||#     ← 右脚1px後（下）
    ####
```

**変更点**:
- 体全体を1px上に移動
- 左脚を1px前（上）に
- 右脚を1px後（下）に

#### Frame 2（両足揃う、体下）

```
    ####
   ##@@##
   #.@@.#
   ######
  ##OOOO##   ← 体全体を通常位置に
  #OOOOOO#
 ##OOOOOO##
 #--OOOO--#
  ##0000##
   #0000#
   ##||##    ← 両脚揃う
    #||#
    ####
```

**変更点**:
- 体を通常位置に
- 両脚を揃える

#### Frame 3（右足前）

```
    ####
   ##@@##
   #.@@.#
   ######
  ##OOOO##   ← 体全体を1px上に
  #OOOOOO#
 ##OOOOOO##
 #--OOOO--#
  ##0000##
   #0000#
    #||##    ← 右脚1px前（上）
   #||#      ← 左脚1px後（下）
    ####
```

**変更点**:
- 体全体を1px上に移動
- 右脚を1px前（上）に
- 左脚を1px後（下）に

#### Frame 4（両足揃う、体下）

```
（Frame 2と同じ）
```

**変更点**: Frame 2に戻る

---

### 2.3 player_hit（被弾アニメーション）

**目的**: ダメージを受けた瞬間の点滅・縮小

#### Frame 1（通常状態）

```
（player_idleのFrame 1と同じ）
```

**変更点**: なし（通常状態）

#### Frame 2（被弾状態）

```
    ####
   ##@@##
   #X@@X#    ← 目が×に変化
   ######
  ##OOOO##   ← 色を赤系に変更（後述）
  #OOOOOO#
 ##OOOO##    ← 全体を1px縮小
 #--OO--#
  ##00##
   #00#
   ####      ← 脚も縮小
```

**変更点**:
- 色を青系→赤系に置換（#4A90E2→#E74C3C）
- 全体を1-2px縮小（ダメージで縮む表現）
- 目を×印に変更（オプション）

---

## 3. 色パレット定義

### 3.1 基本16色パレット

以下の16色を使用してください。**アンチエイリアス厳禁**。

#### アウトライン・基本色

| 色名 | HEX | RGB | 用途 |
|------|-----|-----|------|
| **黒** | `#000000` | (0, 0, 0) | アウトライン、目、影の最暗部 |
| **濃灰** | `#1A1A1A` | (26, 26, 26) | 深い影 |
| **灰** | `#2D2D2D` | (45, 45, 45) | 中間影 |
| **白** | `#FFFFFF` | (255, 255, 255) | ハイライト、目の白目 |

#### プレイヤー・味方カラー（青系）

| 色名 | HEX | RGB | 用途 |
|------|-----|-----|------|
| **メインブルー** | `#4A90E2` | (74, 144, 226) | プレイヤー胴体の基本色 |
| **ライトブルー** | `#7FCDCD` | (127, 205, 205) | ハイライト（光が当たる部分） |
| **ダークブルー** | `#357ABD` | (53, 122, 189) | 影（光が当たらない部分） |

#### 敵カラー（赤系）

| 色名 | HEX | RGB | 用途 |
|------|-----|-----|------|
| **メインレッド** | `#E74C3C` | (231, 76, 60) | 被弾時の体色、敵の基本色 |
| **ダークレッド** | `#C0392B` | (192, 57, 43) | 赤の影 |
| **ライトレッド** | `#FF6B6B` | (255, 107, 107) | 赤のハイライト |

#### アイテム・エフェクトカラー

| 色名 | HEX | RGB | 用途 |
|------|-----|-----|------|
| **オレンジ** | `#F39C12` | (243, 156, 18) | アイテム、炎エフェクト |
| **イエロー** | `#F1C40F` | (241, 196, 15) | 光、レベルアップ |
| **グリーン** | `#2ECC71` | (46, 204, 113) | 回復、ポジティブエフェクト |
| **パープル** | `#9B59B6` | (155, 89, 182) | 特殊エフェクト |
| **ライトグレー** | `#ECF0F1` | (236, 240, 241) | 煙、霧 |
| **ブライトイエロー** | `#FFC300` | (255, 195, 0) | 爆発、閃光 |

### 3.2 色の使い分け例

#### プレイヤーキャラクター（青系）

```
ハイライト（上部・光が当たる）: #7FCDCD
基本色（中央）: #4A90E2
影（下部・光が当たらない）: #357ABD
アウトライン: #000000
目: #FFFFFF（白）+ #000000（瞳）
```

#### 被弾時（赤系）

```
ハイライト: #FF6B6B
基本色: #E74C3C
影: #C0392B
アウトライン: #000000
```

### 3.3 アンチエイリアス禁止の理由

**NG例**:
```
ぼやけた境界（アンチエイリアス有効）:
##@@@@##
#@@@@@@#   ← 境界が半透明でぼやける
```

**OK例**:
```
くっきりした境界（アンチエイリアス無効）:
##@@@@##
#@@@@@@#   ← 境界が明確
```

**Asepriteでの確保方法**:
- **Pencil Tool**（ショートカット: `B`）を使用
- **Brush Tool**は使わない（自動アンチエイリアス有効のため）

---

## 4. Asepriteプロジェクト設定

### 4.1 新規ファイル作成

1. Asepriteを起動
2. `File` → `New...`
3. 以下を設定:

#### player_idle / player_walk の場合

| 設定項目 | 値 |
|---------|-----|
| **Width** | 192 px（48px × 4フレーム） |
| **Height** | 48 px |
| **Color Mode** | RGBA（またはIndexed Color） |
| **Background** | Transparent |

#### player_hit の場合

| 設定項目 | 値 |
|---------|-----|
| **Width** | 96 px（48px × 2フレーム） |
| **Height** | 48 px |
| **Color Mode** | RGBA |
| **Background** | Transparent |

4. `OK` をクリック

### 4.2 Indexed Colorモード（推奨）

色数を16色に制限する場合、Indexed Colorモードを使用します。

1. `File` → `New...` で **Color Mode** を **Indexed** に設定
2. `Palette` → `New Palette...` で新規パレット作成
3. 上記16色パレットを登録

**メリット**:
- 色数が自動で制限される
- ファイルサイズが小さくなる
- アンチエイリアスが発生しない

### 4.3 グリッド設定

1. `View` → `Grid` → `Grid Settings...`
2. 以下を設定:

| 設定項目 | 値 |
|---------|-----|
| **Grid Width** | 48 px（1フレーム単位） |
| **Grid Height** | 48 px |
| **Grid Color** | 白（#FFFFFF）または好みの色 |

3. `View` → `Grid` → `Show Grid` にチェック

### 4.4 ズーム設定

1. `View` → `Zoom` → `800%`（8倍）以上に設定
2. または、マウスホイールで調整

**推奨倍率**: 800%〜1600%

### 4.5 レイヤー構成（推奨）

| レイヤー名 | 用途 | 表示順 |
|-----------|------|--------|
| **Outline** | アウトライン（黒） | 最前面 |
| **Body** | 体の塗り（青系） | 中間 |
| **Background** | ガイド用（エクスポート時は非表示） | 最背面 |

**作成手順**:
1. `Layer` → `New Layer...` で各レイヤーを作成
2. エクスポート時は `Layers` を `Merge` に設定（全て統合）

### 4.6 タグ設定（アニメーション管理）

1. `Frame` → `Tags...`
2. 以下のタグを追加:

#### player_idle の場合

| タグ名 | 開始フレーム | 終了フレーム | Direction |
|-------|------------|------------|----------|
| **idle** | 1 | 4 | Forward |

#### player_walk の場合

| タグ名 | 開始フレーム | 終了フレーム | Direction |
|-------|------------|------------|----------|
| **walk** | 1 | 4 | Forward |

#### player_hit の場合

| タグ名 | 開始フレーム | 終了フレーム | Direction |
|-------|------------|------------|----------|
| **hit** | 1 | 2 | Forward |

### 4.7 フレーム時間設定

各フレームの表示時間を設定します（FPSに対応）。

| モーション | FPS | フレーム時間（ms） |
|-----------|-----|------------------|
| **idle** | 8 | 125 ms |
| **walk** | 12 | 83 ms |
| **hit** | 15 | 66 ms |

**設定手順**:
1. `Frame` → `Frame Properties...`（各フレームを選択）
2. **Duration** に上記の値を入力

または、タイムラインで直接FPS設定:
1. タイムライン右上の `FPS` 欄に値を入力（8、12、15）

---

## 5. エクスポート手順

### 5.1 スプライトシートエクスポート

1. `File` → `Export Sprite Sheet...`
2. 以下を設定:

#### 基本設定

| 設定項目 | 値 |
|---------|-----|
| **Sheet Type** | Horizontal Strip（横一列） |
| **Layers** | Merge（全レイヤー統合） |
| **Frames** | All Frames |
| **Trim Cels** | **OFF（重要！）** |
| **Padding** | 0 px |
| **Border Padding** | 0 px |

#### Output設定

| モーション | ファイル名 | 期待サイズ |
|-----------|-----------|----------|
| **idle** | `player_idle_48x48_4f.png` | 192×48 px |
| **walk** | `player_walk_48x48_4f.png` | 192×48 px |
| **hit** | `player_hit_48x48_2f.png` | 96×48 px |

3. `Output File` に上記ファイル名を入力
4. `Export` をクリック

### 5.2 エクスポート後の確認

エクスポートしたPNGファイルを画像ビューアで開き、以下を確認:

- [ ] サイズが正しい（192×48 または 96×48）
- [ ] フレームが横一列に並んでいる
- [ ] 背景が透過（チェッカーボード表示）
- [ ] アウトラインがくっきり（ぼやけていない）
- [ ] フレーム間に余白がない

### 5.3 コマンドラインエクスポート（上級者向け）

Asepriteをコマンドラインで実行してバッチエクスポート可能です。

```bash
# idle
aseprite -b player_idle.aseprite \
  --sheet player_idle_48x48_4f.png \
  --format json-array \
  --list-tags \
  --sheet-type horizontal

# walk
aseprite -b player_walk.aseprite \
  --sheet player_walk_48x48_4f.png \
  --format json-array \
  --list-tags \
  --sheet-type horizontal

# hit
aseprite -b player_hit.aseprite \
  --sheet player_hit_48x48_2f.png \
  --format json-array \
  --list-tags \
  --sheet-type horizontal
```

**オプション説明**:
- `-b`: バックグラウンドモード（GUIを開かない）
- `--sheet`: 出力ファイル名
- `--format json-array`: メタデータをJSON出力（オプション）
- `--sheet-type horizontal`: 横一列配置

---

## 6. Godot SpriteFrames作成手順

### 6.1 ファイル配置

エクスポートしたPNGファイルを以下に配置:

```
res://assets/characters/player/
├── player_idle_48x48_4f.png
├── player_walk_48x48_4f.png
├── player_hit_48x48_2f.png
└── player_frames.tres（これから作成）
```

### 6.2 AnimatedSprite2Dノード作成

1. Godotエディタでシーンを開く
2. シーンツリーで `+` ボタン → `AnimatedSprite2D` を検索
3. ノード名を `Player` に変更

### 6.3 SpriteFramesリソース作成

1. `Inspector` パネルで `Sprite Frames` プロパティを探す
2. `<empty>` をクリック → `New SpriteFrames` を選択
3. 作成された `SpriteFrames` をクリック
4. 画面下部に `SpriteFrames` パネルが表示される

### 6.4 アニメーション追加

#### idle アニメーション

1. `SpriteFrames` パネルで `default` を削除（右クリック → Delete）
2. `Add Animation` ボタン（+）をクリック
3. アニメーション名を `idle` に変更
4. `Add Frames from Sprite Sheet` ボタンをクリック
5. `player_idle_48x48_4f.png` を選択
6. スライス設定:
   - **Horizontal**: 4
   - **Vertical**: 1
7. 全フレームを選択（Shift+クリック）
8. `Add 4 Frame(s)` をクリック
9. `Speed (FPS)` を **8** に設定

#### walk アニメーション

1. `Add Animation` ボタン → `walk` に命名
2. `Add Frames from Sprite Sheet` → `player_walk_48x48_4f.png`
3. スライス設定: Horizontal=4、Vertical=1
4. 全フレーム追加
5. `Speed (FPS)` を **12** に設定

#### hit アニメーション

1. `Add Animation` ボタン → `hit` に命名
2. `Add Frames from Sprite Sheet` → `player_hit_48x48_2f.png`
3. スライス設定: Horizontal=2、Vertical=1
4. 全フレーム追加
5. `Speed (FPS)` を **15** に設定
6. **Loop** を **OFF** に設定（one-shot再生）

### 6.5 SpriteFrames保存

1. `Inspector` パネルで `Sprite Frames` プロパティの右側の `▼` をクリック
2. `Save` を選択
3. 保存先: `res://assets/characters/player/player_frames.tres`
4. `Save` をクリック

### 6.6 GDScriptで使用

```gdscript
extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
    # 待機アニメーション再生
    animated_sprite.play("idle")

func _physics_process(delta):
    var velocity = Vector2.ZERO

    # 入力取得
    if Input.is_action_pressed("ui_right"):
        velocity.x += 1
    if Input.is_action_pressed("ui_left"):
        velocity.x -= 1
    if Input.is_action_pressed("ui_down"):
        velocity.y += 1
    if Input.is_action_pressed("ui_up"):
        velocity.y -= 1

    # アニメーション切り替え
    if velocity.length() > 0:
        animated_sprite.play("walk")
        # 移動方向に回転（上向きスプライト前提）
        animated_sprite.rotation = velocity.angle() + PI/2
    else:
        animated_sprite.play("idle")

    # 移動処理
    velocity = velocity.normalized() * 200
    move_and_slide()

# 被弾時の処理
func take_damage():
    animated_sprite.play("hit")
    # hitアニメーション終了後にidleに戻す
    await animated_sprite.animation_finished
    animated_sprite.play("idle")
```

---

## 7. トラブルシューティング

### 7.1 スプライトがぼやける

**症状**: ピクセルアートがぼやけて表示される

**原因**: Filter設定が `Linear` になっている

**対処法**:
1. `Project` → `Project Settings...`
2. `Rendering` → `Textures` → `Canvas Textures`
3. **Default Texture Filter** を `Nearest` に変更

または、個別設定:
1. PNGファイルを選択
2. `Import` タブで `Filter` を `false` に設定
3. `Reimport` をクリック

### 7.2 スプライトが1pxずつブレる

**症状**: 移動時にキャラが微妙にブレる

**原因**: Pixel Snapが無効

**対処法**:
1. `Project` → `Project Settings...`
2. `Rendering` → `2D` → `Snapping`
3. **Use Gpu Pixel Snap** を `true` に設定

### 7.3 エクスポートサイズが違う

**症状**: 192×48pxのはずが別のサイズ

**原因**: `Trim Cels` が有効

**対処法**:
1. `File` → `Export Sprite Sheet...`
2. **Trim Cels** のチェックを外す
3. **Padding** を `0` に設定

### 7.4 透過部分が黒くなる

**症状**: 背景が透過せず黒く表示される

**原因1**: Asepriteで背景を透過にしていない

**対処法**:
1. `File` → `New...` で **Background** を `Transparent` に設定

**原因2**: Godotのインポート設定

**対処法**:
1. PNGファイルを選択
2. `Import` タブで `Premult Alpha` を `false` に設定
3. `Reimport` をクリック

### 7.5 アニメーションが再生されない

**症状**: AnimatedSprite2Dが静止画のまま

**原因**: アニメーションが再生されていない

**対処法**:
```gdscript
# _ready()で再生開始
$AnimatedSprite2D.play("idle")
```

### 7.6 hit アニメーションがループする

**症状**: 被弾アニメが無限ループする

**原因**: Loop設定がON

**対処法**:
1. `SpriteFrames` パネルで `hit` アニメを選択
2. **Loop** を **OFF** に設定

### 7.7 色が左右反転で変わる

**症状**: 回転時に色が変わる

**原因**: テクスチャ圧縮の問題

**対処法**:
1. PNGファイルを選択
2. `Import` タブで `Compress` → `Mode` を `Lossless` に変更
3. `Reimport` をクリック

### 7.8 フレームが崩れる

**症状**: 一部のフレームが欠けている

**原因**: スライス設定が間違っている

**対処法**:
1. `Add Frames from Sprite Sheet` で再設定
2. **Horizontal** と **Vertical** の値を確認
3. idle/walk=4×1、hit=2×1

---

## デザイナーが最初にすべきアクション

### ステップ1: Asepriteプロジェクト作成（5分）

1. Asepriteを起動
2. `File` → `New...`
   - Width: 192px
   - Height: 48px
   - Color Mode: RGBA
   - Background: Transparent
3. `File` → `Save As...` → `player_idle.aseprite`

### ステップ2: パレット登録（5分）

1. `Edit` → `Palette...`
2. 上記16色パレットを登録
3. パレットを保存: `Palette` → `Save Palette As...` → `player_palette.gpl`

### ステップ3: 基準フレーム作成（30分）

1. ズームを800%に設定
2. Pencil Tool（`B`）で黒アウトラインを描く
3. 上記ASCIIアートを参考に、48×48pxの中央にキャラを配置
4. Paint Bucket（`G`）で青系パレットを塗る

### ステップ4: アニメーション作成（60分）

1. `Frame` → `New Frame`（3回）で計4フレーム作成
2. 各フレームを上記指示通りに調整
3. タイムラインで再生確認（8 FPS）

### ステップ5: エクスポート（5分）

1. `File` → `Export Sprite Sheet...`
2. Output: `player_idle_48x48_4f.png`
3. Sheet Type: Horizontal Strip
4. Trim Cels: OFF
5. `Export`

### ステップ6: walk / hit も同様に作成（90分）

- `player_walk.aseprite` を新規作成
- `player_hit.aseprite` を新規作成
- 各モーションをエクスポート

### ステップ7: Godotで確認（15分）

1. PNGファイルを `res://assets/characters/player/` に配置
2. SpriteFramesリソースを作成
3. アニメーション再生確認

---

## まとめ

このテンプレートに従えば、以下が完成します:

- ✅ `player_idle_48x48_4f.png`（192×48px、4フレーム、8FPS）
- ✅ `player_walk_48x48_4f.png`（192×48px、4フレーム、12FPS）
- ✅ `player_hit_48x48_2f.png`（96×48px、2フレーム、15FPS）
- ✅ `player_frames.tres`（Godot SpriteFrames）

**所要時間**: 約3-4時間（初心者の場合）

**参考資料**:
- 仕様書: `docs/asset-specifications.md`
- 作成ガイド: `docs/asset-creation-guide.md`
- ディレクトリ構造: `assets/characters/README.md`
