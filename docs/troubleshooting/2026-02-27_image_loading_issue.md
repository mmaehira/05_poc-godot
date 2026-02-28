# 画像読み込みイシュー: Godotのリソースシステムを正しく使用する

**日付:** 2026-02-27
**影響範囲:** PlayerVisual, 動的画像ロード処理
**重要度:** 🔴 High（ゲームの見た目に直結）

## 問題の概要

プレイヤーのスプライト画像が正しく表示されず、フォールバック処理（青い四角形）が表示される問題が発生していました。

## 根本原因

### ❌ 誤った実装

**ファイル:** `scripts/player/player_visual.gd:84-103`（修正前）

```gdscript
func _load_image(path: String) -> ImageTexture:
	var image = Image.new()
	var file_path = path.replace("res://", "/workspaces/05_poc-godot/")

	var error = image.load(file_path)
	if error != OK:
		push_error("[PlayerVisual] Failed to load image: " + path)
		return null

	# ... 以下リサイズ処理
```

**問題点:**

1. **ファイルシステムから直接読み込み**
   - `Image.load(file_path)` は絶対パスでファイルを直接読み込む
   - Godotのインポートシステムをバイパスしている

2. **インポート設定の無視**
   - `.import` ファイルで定義されたテクスチャ設定を無視
   - 圧縮形式、ミップマップ、フィルタリング設定が適用されない

3. **リソースキャッシュの未使用**
   - 同じ画像を複数回ロードするとメモリ効率が悪い
   - Godotの最適化が効かない

4. **環境依存性**
   - `/workspaces/05_poc-godot/` という絶対パスに依存
   - エクスポート後や別環境で動作しない

## 正しい実装

### ✅ 修正後の実装

**ファイル:** `scripts/player/player_visual.gd:86-114`

```gdscript
func _load_image(path: String) -> ImageTexture:
	# Godotのリソースシステムを使用して画像をロード
	print("[PlayerVisual] Attempting to load: " + path)
	var texture_resource = load(path)

	if texture_resource == null:
		push_error("[PlayerVisual] Failed to load image: " + path)
		return null

	print("[PlayerVisual] Successfully loaded: " + path)

	# Texture2Dとして使用可能か確認
	if not texture_resource is Texture2D:
		push_error("[PlayerVisual] Resource is not a Texture2D: " + path)
		return null

	# リサイズが必要な場合
	var texture_2d = texture_resource as Texture2D
	var img = texture_2d.get_image()

	if img == null:
		push_error("[PlayerVisual] Failed to get image from texture: " + path)
		return null

	# DALL-E生成画像を目標サイズにリサイズ
	if img.get_height() > TARGET_SPRITE_SIZE:
		var scale_factor = float(TARGET_SPRITE_SIZE) / float(img.get_height())
		var new_width = int(img.get_width() * scale_factor)
		var new_height = TARGET_SPRITE_SIZE
		img.resize(new_width, new_height, Image.INTERPOLATE_LANCZOS)

	return ImageTexture.create_from_image(img)
```

## 修正のポイント

### 1. `load()` 関数の使用

```gdscript
var texture_resource = load(path)  // ✅ 正しい
```

- Godotのグローバル関数 `load()` を使用
- `res://` パスをそのまま使用
- インポート設定を尊重

### 2. 型チェックの追加

```gdscript
if not texture_resource is Texture2D:
	push_error("Resource is not a Texture2D")
	return null
```

- ロードしたリソースが期待する型か確認
- デバッグ情報を明確に出力

### 3. エラーハンドリングの強化

```gdscript
print("[PlayerVisual] Attempting to load: " + path)
// ...
print("[PlayerVisual] Successfully loaded: " + path)
```

- ロード成功/失敗を明確にログ出力
- トラブルシューティングが容易

## 動作確認結果

### ✅ 修正後のログ出力

```
[PlayerVisual] Loading player sprites...
[PlayerVisual] Attempting to load: res://assets/characters/player/player_idle_48x48_4f.png
[PlayerVisual] Successfully loaded: res://assets/characters/player/player_idle_48x48_4f.png
[PlayerVisual] Attempting to load: res://assets/characters/player/player_walk_48x48_4f.png
[PlayerVisual] Successfully loaded: res://assets/characters/player/player_walk_48x48_4f.png
[PlayerVisual] Attempting to load: res://assets/characters/player/player_hit_48x48_2f.png
[PlayerVisual] Successfully loaded: res://assets/characters/player/player_hit_48x48_2f.png
```

### 使用されるアセット

| ファイル | サイズ | フレーム数 | 用途 |
|---------|--------|-----------|------|
| `player_idle_48x48_4f.png` | 726KB | 4 | アイドルアニメーション |
| `player_walk_48x48_4f.png` | 625KB | 4 | 歩行アニメーション |
| `player_hit_48x48_2f.png` | 723KB | 2 | ダメージアニメーション |

## Godotのリソースシステム - ベストプラクティス

### ✅ 推奨される方法

```gdscript
# 静的ロード（コンパイル時）
@export var texture: Texture2D

# 動的ロード（ランタイム）
var texture = load("res://path/to/texture.png")

# 非同期ロード（大きなリソース）
var texture = await ResourceLoader.load_threaded_get("res://path/to/texture.png")
```

### ❌ 避けるべき方法

```gdscript
# ファイルシステムから直接読み込み
var image = Image.new()
image.load("/absolute/path/to/file.png")  # NG!

# res:// を手動で置き換え
var path = "res://texture.png".replace("res://", "/project/path/")  # NG!
```

## 教訓・学び

### 🎓 重要な原則

1. **Godotの抽象化を信頼する**
   - Godotが提供するAPIを使う
   - 低レベルAPIに直接アクセスしない

2. **リソースパスは `res://` で統一**
   - 環境依存のパスを使わない
   - エクスポート時の互換性を保つ

3. **インポートシステムを活用**
   - `.import` ファイルの設定を尊重
   - テクスチャ最適化の恩恵を受ける

4. **エラーハンドリングを丁寧に**
   - 失敗時の原因を特定しやすくする
   - デバッグログを充実させる

## 参考リンク

- [Godot Docs - Importing images](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html)
- [Godot Docs - Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Godot Docs - File system](https://docs.godotengine.org/en/stable/tutorials/scripting/filesystem.html)

## 関連ファイル

- `scripts/player/player_visual.gd:86-114` - 修正後の画像ロード処理
- `assets/characters/player/*.png` - プレイヤースプライト画像
- `assets/characters/player/*.import` - Godotインポート設定

## タグ

`#godot` `#resource-loading` `#texture` `#sprite` `#best-practices` `#troubleshooting`
