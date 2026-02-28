# Audio Assets

BGMとSEを配置するディレクトリです。

## 📖 詳細仕様

👉 **[docs/asset-specifications.md](../../docs/asset-specifications.md)** の「4. BGM/SE仕様」を参照

## 📁 サブディレクトリ

- `bgm/` - バックグラウンドミュージック
- `se/` - 効果音（サウンドエフェクト）

## 🎵 BGM仕様

| 項目 | 仕様 |
|------|------|
| フォーマット | OGG Vorbis (.ogg) |
| サンプルレート | 44100Hz |
| ビットレート | 128kbps（可変） |
| チャンネル | Stereo (2ch) |
| ループ | 有（メタデータ埋め込み） |
| 推奨尺 | 60〜120秒 |

### 必要なBGM
- [ ] `bgm_title_120.ogg` - タイトル画面用
- [ ] `bgm_gameplay_140.ogg` - 通常戦闘用
- [ ] `bgm_boss_160.ogg` - ボス戦用

## 🔊 SE仕様

| 項目 | 仕様 |
|------|------|
| フォーマット | OGG Vorbis (.ogg) |
| サンプルレート | 44100Hz |
| ビットレート | 96kbps（可変） |
| チャンネル | Mono (1ch) |
| ループ | 無 |
| 推奨尺 | 0.1〜2秒 |

### 必要なSE（13種類）
- [ ] `se_shoot_01.ogg` 〜 `se_shoot_03.ogg` - 武器発射（3バリエーション）
- [ ] `se_explosion_small.ogg` - 敵撃破
- [ ] `se_explosion_large.ogg` - ボス撃破
- [ ] `se_hit_player.ogg` - プレイヤー被弾
- [ ] `se_pickup_exp.ogg` - EXP取得
- [ ] `se_levelup.ogg` - レベルアップ
- [ ] `se_powerup.ogg` - アイテム取得
- [ ] `se_skill_activate.ogg` - スキル使用
- [ ] `se_ui_select.ogg` - ボタンフォーカス
- [ ] `se_ui_confirm.ogg` - ボタン押下
- [ ] `se_boss_warning.ogg` - ボス出現警告

## 🔧 ループ設定

BGMにループポイントを設定する場合、OGGコメントタグで指定：
```
LOOPSTART=<sample_number>
LOOPLENGTH=<sample_count>
```

Godot側では `AudioStreamOGGVorbis.loop = true` で自動ループ可能。
