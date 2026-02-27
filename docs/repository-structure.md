# repository-structure.md
リポジトリ構造定義書

---

# 1. ディレクトリ構造全体像

```
05_poc-godot/
├── .devcontainer/          # Devcontainer設定
│   └── devcontainer.json
├── .git/                   # Git管理（自動生成）
├── .gitignore              # Git除外設定
├── CLAUDE.md               # Claude Code用プロジェクトメモリ
├── project.godot           # Godotプロジェクト設定ファイル
├── autoload/               # Autoloadスクリプト（Singleton）
│   ├── game_manager.gd
│   ├── level_system.gd
│   └── pool_manager.gd
├── resources/              # Resource定義（データ）
│   ├── game_stats.gd
│   ├── weapon.gd
│   ├── ai_controller.gd
│   ├── ai_chase_player.gd
│   └── weapons/            # 武器データ
│       ├── straight_shot.tres
│       ├── area_blast.tres
│       └── homing_missile.tres
├── scenes/                 # Godotシーンファイル
│   ├── main.tscn
│   ├── title.tscn
│   ├── game.tscn
│   ├── player/
│   │   └── player.tscn
│   ├── enemies/
│   │   ├── basic_enemy.tscn
│   │   └── strong_enemy.tscn
│   ├── weapons/
│   │   └── projectile.tscn
│   ├── items/
│   │   └── exp_orb.tscn
│   └── ui/
│       ├── hud.tscn
│       ├── upgrade_panel.tscn
│       └── game_over_screen.tscn
├── scripts/                # GDScriptファイル
│   ├── player/
│   │   ├── player.gd
│   │   └── weapon_manager.gd
│   ├── weapons/
│   │   ├── weapon_instance.gd
│   │   └── projectile.gd
│   ├── enemies/
│   │   ├── enemy.gd
│   │   ├── basic_enemy.gd
│   │   └── strong_enemy.gd
│   ├── items/
│   │   └── exp_orb.gd
│   ├── systems/
│   │   ├── enemy_spawner.gd
│   │   ├── upgrade_generator.gd
│   │   └── upgrade_applier.gd
│   ├── ui/
│   │   ├── hud.gd
│   │   ├── upgrade_panel.gd
│   │   └── game_over_screen.gd
│   └── debug/              # デバッグツール（将来的）
│       └── performance_monitor.gd
├── assets/                 # ゲームアセット
│   ├── sprites/            # 画像ファイル
│   │   ├── player/
│   │   ├── enemies/
│   │   ├── weapons/
│   │   └── ui/
│   ├── sounds/             # 音声ファイル（将来的）
│   └── fonts/              # フォントファイル
├── addons/                 # Godotプラグイン（将来的）
│   ├── custom_weapons/
│   ├── boss_battles/
│   └── persistent_upgrades/
├── mods/                   # ユーザーMod配置（将来的）
├── build/                  # ビルド成果物（.gitignore対象）
├── docs/                   # プロジェクトドキュメント
│   ├── product-requirements.md
│   ├── functional-design.md
│   ├── architecture.md
│   ├── repository-structure.md (本ファイル)
│   ├── development-guidelines.md
│   └── glossary.md
└── .steering/              # 作業単位のステアリングファイル
    └── [YYYYMMDD]-[開発タイトル]/
        ├── requirements.md
        ├── design.md
        └── tasklist.md
```

---

# 2. ディレクトリ別の役割

## 2.1 `.devcontainer/`
### 役割
- VSCode Devcontainer設定
- 開発環境の再現性確保

### ファイル
- `devcontainer.json`: コンテナ定義、拡張機能、起動コマンド

### 管理方針
- プロジェクト初期に作成
- 基本的に変更しない

---

## 2.2 `autoload/`
### 役割
- Godot Autoload（Singleton）スクリプト配置
- ゲーム全体で共有する状態管理

### ファイル規則
- `game_manager.gd`: ゲーム状態管理
- `level_system.gd`: 経験値・レベル管理
- `pool_manager.gd`: オブジェクトプール管理

### 管理方針
- **MVP時点でのAutoload**: GameManager, LevelSystem, PoolManagerの3つのみ
- シーンに配置せず、`project.godot`で登録
- グローバル状態の肥大化を避ける

### 将来的な拡張
- Logger (autoload/logger.gd) - 構造化ログシステム
- その他必要に応じて追加可能だが、最小限に抑える

---

## 2.3 `resources/`
### 役割
- Godot Resourceクラス定義
- データ駆動設計のデータ層

### ディレクトリ構造
```
resources/
├── game_stats.gd           # ゲーム統計Resource
├── weapon.gd               # 武器基底Resource
├── ai_controller.gd        # AI基底Resource
├── ai_chase_player.gd      # 具体的AI実装
└── weapons/                # 武器データ（.tres）
    ├── straight_shot.tres
    ├── area_blast.tres
    └── homing_missile.tres
```

### ファイル規則
- `.gd`: Resourceクラス定義
- `.tres`: Resourceインスタンス（データ）

### 命名規則
- クラス: `PascalCase`（例: `AIController`）
- ファイル: `snake_case.gd`（例: `ai_controller.gd`）
- インスタンス: `snake_case.tres`（例: `straight_shot.tres`）

---

## 2.4 `scenes/`
### 役割
- Godotシーンファイル（`.tscn`）配置
- ゲームオブジェクトの構造定義

### ディレクトリ構造
```
scenes/
├── main.tscn               # エントリーポイント
├── title.tscn              # タイトル画面
├── game.tscn               # メインゲームシーン
├── player/                 # プレイヤー関連
│   └── player.tscn
├── enemies/                # 敵関連
│   ├── basic_enemy.tscn
│   └── strong_enemy.tscn
├── weapons/                # 武器関連
│   └── projectile.tscn
├── items/                  # アイテム関連
│   └── exp_orb.tscn
└── ui/                     # UI関連
    ├── hud.tscn
    ├── upgrade_panel.tscn
    └── game_over_screen.tscn
```

### ファイル規則
- **テキスト形式（`.tscn`）必須**: Git差分管理のため
- バイナリ形式（`.scn`）は使用しない

### 命名規則
- `snake_case.tscn`
- 例: `game_over_screen.tscn`

---

## 2.5 `scripts/`
### 役割
- GDScriptファイル配置
- ゲームロジック実装

### ディレクトリ構造
```
scripts/
├── player/
│   ├── player.gd
│   └── weapon_manager.gd
├── weapons/
│   ├── weapon_instance.gd
│   └── projectile.gd
├── enemies/
│   ├── enemy.gd
│   ├── basic_enemy.gd
│   └── strong_enemy.gd
├── items/
│   └── exp_orb.gd
├── systems/
│   ├── enemy_spawner.gd
│   ├── upgrade_generator.gd
│   └── upgrade_applier.gd
├── ui/
│   ├── hud.gd
│   ├── upgrade_panel.gd
│   └── game_over_screen.gd
└── debug/
    └── performance_monitor.gd
```

### ファイル配置ルール
1. **シーンと1:1対応**: `player.tscn` → `player.gd`
2. **カテゴリ別サブディレクトリ**: player/, enemies/, weapons/, items/, systems/, ui/
3. **基底クラス**: サブディレクトリのルートに配置（例: `enemy.gd`）
4. **デバッグツール**: debug/ サブディレクトリに配置（将来的）

### 命名規則
- `snake_case.gd`
- クラス名: `PascalCase`（例: `class_name Player`）

---

## 2.6 `assets/`
### 役割
- ゲームアセット（画像、音声、フォント）配置

### ディレクトリ構造
```
assets/
├── characters/
│   ├── player/
│   │   ├── player_idle_48x48_4f.png
│   │   ├── player_walk_48x48_4f.png
│   │   ├── player_hit_48x48_2f.png
│   │   └── player_frames.tres
│   ├── enemies/
│   │   ├── basic_enemy_idle_32x32_4f.png
│   │   ├── basic_enemy_frames.tres
│   │   ├── strong_enemy_idle_40x40_4f.png
│   │   ├── strong_enemy_frames.tres
│   │   ├── fast_enemy_idle_28x28_4f.png
│   │   ├── fast_enemy_frames.tres
│   │   ├── heavy_enemy_idle_56x56_4f.png
│   │   └── heavy_enemy_frames.tres
│   └── bosses/
│       ├── tank_boss_idle_96x96_6f.png
│       ├── tank_boss_frames.tres
│       ├── sniper_boss_idle_80x80_6f.png
│       ├── sniper_boss_frames.tres
│       ├── swarm_boss_idle_88x88_6f.png
│       └── swarm_boss_frames.tres
├── weapons/
│   └── projectiles/
│       ├── straight_shot_projectile_16x16.png
│       ├── area_blast_projectile_24x24_4f.png
│       ├── homing_missile_projectile_20x20_4f.png
│       ├── laser_beam_projectile_8x32.png
│       ├── lightning_projectile_16x48_4f.png
│       └── orbital_projectile_20x20_4f.png
├── items/
│   ├── exp_orb_small_12x12_4f.png
│   ├── exp_orb_medium_16x16_4f.png
│   ├── exp_orb_large_20x20_4f.png
│   ├── powerup_item_24x24_4f.png
│   └── magnet_item_24x24_4f.png
├── effects/
│   ├── explosion_effect_64x64_6f.png
│   ├── muzzle_flash_effect_32x32_6f.png
│   ├── level_up_effect_96x96_6f.png
│   ├── hit_spark_effect_24x24_4f.png
│   ├── powerup_aura_effect_64x64_4f.png
│   └── particles/
│       ├── spark_small_particle_8x8.png
│       ├── spark_medium_particle_12x12.png
│       ├── smoke_particle_16x16.png
│       ├── glow_particle_32x32.png
│       └── trail_particle_8x8.png
├── environment/
│   ├── tileset_ground_32x32.png
│   ├── tileset_wall_32x32.png
│   ├── decoration_atlas_256x256.png
│   └── tileset_main.tres
├── ui/
│   ├── buttons/
│   │   ├── button_small_128x48.png
│   │   ├── button_medium_192x64.png
│   │   └── button_large_256x80.png
│   ├── panels/
│   │   ├── panel_small_256x192.png
│   │   ├── panel_medium_512x384.png
│   │   └── panel_large_768x576.png
│   ├── gauges/
│   │   ├── hp_gauge_bg_256x32.png
│   │   ├── hp_gauge_fg_248x24.png
│   │   ├── exp_gauge_bg_512x16.png
│   │   ├── exp_gauge_fg_504x12.png
│   │   ├── boss_hp_bg_768x48.png
│   │   └── boss_hp_fg_752x36.png
│   ├── icons/
│   │   ├── icon_frame_64x64.png
│   │   └── (各武器・スキルアイコン56x56)
│   └── misc/
│       ├── combo_bg_256x96.png
│       └── skill_cooldown_circle_80x80.png
└── audio/
    ├── bgm/
    │   ├── bgm_title_120.ogg
    │   ├── bgm_gameplay_140.ogg
    │   └── bgm_boss_160.ogg
    └── se/
        ├── se_shoot_01.ogg
        ├── se_shoot_02.ogg
        ├── se_shoot_03.ogg
        ├── se_explosion_small.ogg
        ├── se_explosion_large.ogg
        ├── se_hit_player.ogg
        ├── se_pickup_exp.ogg
        ├── se_levelup.ogg
        ├── se_powerup.ogg
        ├── se_skill_activate.ogg
        ├── se_ui_select.ogg
        ├── se_ui_confirm.ogg
        └── se_boss_warning.ogg
```

### ファイル規則
- **画像**: PNG（RGB+Alpha、透過対応）
- **音声**: OGG Vorbis（.ogg）- BGM/SE統一
- **フォント**: TTF/OTF（将来的）
- **スプライトシート**: 命名規則 `{object}_{motion}_{size}_{frames}f.png`
- **SpriteFrames**: `.tres`ファイル、スプライトシートと同じディレクトリ配置

### 命名規則
- **スプライトシート**: `{type}_{motion}_{width}x{height}_{frames}f.png`
  - 例: `player_idle_48x48_4f.png`（48×48サイズ、4フレーム）
- **静止画**: `{type}_{size}.png`
  - 例: `straight_shot_projectile_16x16.png`
- **Audio**: `{category}_{name}_{variant}.ogg`
  - 例: `se_shoot_01.ogg`, `bgm_gameplay_140.ogg`（140はBPM）

### アセット仕様
詳細なアセット仕様は **`docs/asset-specifications.md`** を参照。
- 基準タイルサイズ: 32px × 32px
- プレイヤー表示サイズ: 48px × 48px
- 向き: 上向き固定 + スプライト回転（rotation使用）
- 描画方針: ピクセルアート（Filter=Nearest、Mipmaps=無効）
- 最大テクスチャサイズ: 2048×2048

---

## 2.7 `docs/`
### 役割
- プロジェクトドキュメント配置
- 設計書、仕様書、ガイドライン

### ファイル一覧（永続的ドキュメント）
1. `product-requirements.md` - プロダクト要求定義書
2. `functional-design.md` - 機能設計書
3. `architecture.md` - 技術仕様書
4. `asset-specifications.md` - アセット仕様書
5. `repository-structure.md` - リポジトリ構造定義書（本ファイル）
6. `development-guidelines.md` - 開発ガイドライン
7. `glossary.md` - ユビキタス言語定義

### 管理方針
- **Markdown形式**
- **Git管理対象**
- **基本設計が変わらない限り更新しない**

---

## 2.8 `.steering/`
### 役割
- 作業単位のステアリングファイル配置
- 特定の開発作業に特化したドキュメント

### ディレクトリ構造
```
.steering/
├── 20260226-initial-implementation/
│   ├── requirements.md
│   ├── design.md
│   └── tasklist.md
└── 20260305-add-boss-battle/
    ├── requirements.md
    ├── design.md
    └── tasklist.md
```

### 命名規則
- `[YYYYMMDD]-[開発タイトル]/`
- 例: `20260226-initial-implementation/`

### ファイル内容
- `requirements.md`: 今回の作業の要求内容
- `design.md`: 変更内容の設計
- `tasklist.md`: 具体的な実装タスク

### 管理方針
- **作業ごとに新規ディレクトリ作成**
- **作業完了後は履歴として保持**
- **新しい作業では新しいディレクトリ**

---

## 2.9 `addons/`
### 役割
- Godotプラグインシステム用ディレクトリ
- カスタム機能の拡張モジュール配置

### ディレクトリ構造（将来的）
```
addons/
├── custom_weapons/     # 武器追加プラグイン
│   ├── plugin.cfg
│   └── weapons/
├── boss_battles/       # ボス戦プラグイン
│   ├── plugin.cfg
│   └── bosses/
└── persistent_upgrades/ # 永続強化プラグイン
    ├── plugin.cfg
    └── upgrades/
```

### 管理方針
- **MVP範囲外**: 現時点では未実装
- 将来的な機能拡張時に追加
- 各プラグインは`plugin.cfg`で設定

---

## 2.10 `mods/`
### 役割
- ユーザー作成Modの配置ディレクトリ
- `.pck`ファイルによる動的コンテンツロード

### 管理方針
- **MVP範囲外**: 現時点では未実装
- 将来的なMod対応時に使用
- `.gitignore`で除外（ユーザー個別のコンテンツ）

---

## 2.11 `build/`
### 役割
- ビルド成果物の出力先
- プラットフォーム別の実行ファイル配置

### ディレクトリ構造
```
build/
├── linux/
│   └── game.x86_64
├── windows/
│   └── game.exe
└── html5/
    └── index.html
```

### 管理方針
- **Git管理対象外**（`.gitignore`で除外）
- ビルド時に自動生成
- CI/CD環境でも使用

---

# 3. ファイル配置ルール

## 3.1 シーンとスクリプトの対応

### 原則
- シーン（`.tscn`）とスクリプト（`.gd`）は別ディレクトリ
- `scenes/` と `scripts/` で対称的な構造

### 例
```
scenes/player/player.tscn  →  scripts/player/player.gd
scenes/enemies/basic_enemy.tscn  →  scripts/enemies/basic_enemy.gd
```

### 理由
- 大規模化時の管理しやすさ
- シーンとロジックの明確な分離

---

## 3.2 Resource配置

### `.gd` ファイル
- `resources/` 直下に基底クラス
- サブディレクトリに具体的実装

### `.tres` ファイル
- `resources/` のサブディレクトリに配置
- データの種類ごとにディレクトリ分け

### 例
```
resources/weapon.gd  (基底クラス)
resources/weapons/straight_shot.tres  (データ)
```

---

## 3.3 Autoloadスクリプト

### 配置場所
- `autoload/` ディレクトリ**のみ**

### 登録方法
- `project.godot` で手動登録
- または Godotエディタの「プロジェクト設定 > Autoload」

### 例
```ini
[autoload]
GameManager="*res://autoload/game_manager.gd"
LevelSystem="*res://autoload/level_system.gd"
PoolManager="*res://autoload/pool_manager.gd"
```

---

# 4. 特殊ファイル

## 4.1 `project.godot`
### 役割
- Godotプロジェクト設定の中心ファイル
- エンジンバージョン、入力マッピング、Autoload定義

### 管理方針
- **Git管理対象**
- 手動編集可能だが、Godotエディタ経由を推奨

### 重要セクション
```ini
[application]
config/name="POC Godot Roguelight"
run/main_scene="res://scenes/main.tscn"

[autoload]
GameManager="*res://autoload/game_manager.gd"
LevelSystem="*res://autoload/level_system.gd"
PoolManager="*res://autoload/pool_manager.gd"

[input]
ui_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"pressed":false,"keycode":4194319,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
]
}
```

---

## 4.2 `.gitignore`
### 役割
- Git管理対象外ファイルの定義

### 内容
```gitignore
# Godot自動生成ファイル
.import/
*.import
.godot/
export_presets.cfg

# ビルド成果物
build/
*.x86_64
*.exe
*.pck

# ユーザーMod（個別コンテンツ）
mods/

# OS固有
.DS_Store
Thumbs.db

# エディタ
.vscode/
.idea/

# 一時ファイル
*.log
*.tmp
```

---

## 4.3 `CLAUDE.md`
### 役割
- Claude Code用のプロジェクトメモリ
- 開発ルール、よく使うコマンド

### 配置場所
- リポジトリルート

### 管理方針
- プロジェクト全体のナレッジベース
- 永続的ドキュメントの要約

---

# 5. 命名規則まとめ

| 対象 | 規則 | 例 |
|------|------|-----|
| ディレクトリ | `snake_case` | `autoload/`, `enemy_spawner/` |
| シーンファイル | `snake_case.tscn` | `player.tscn`, `game_over_screen.tscn` |
| スクリプトファイル | `snake_case.gd` | `player.gd`, `weapon_instance.gd` |
| クラス名 | `PascalCase` | `Player`, `WeaponManager` |
| Resourceファイル | `snake_case.tres` | `straight_shot.tres` |
| 変数・関数 | `snake_case` | `current_hp`, `add_exp()` |
| 定数 | `SCREAMING_SNAKE_CASE` | `MAX_WEAPONS`, `DEBUG_MODE` |
| シグナル | `snake_case` | `level_up`, `hp_changed` |

---

# 6. Git管理方針

## 6.1 ブランチ戦略（将来的）
- **main**: 安定版
- **dev**: 開発ブランチ
- **feature/xxx**: 機能追加
- **fix/xxx**: バグ修正

## 6.2 コミットメッセージ
```
[種類] 簡潔な変更内容

詳細説明（必要に応じて）

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

### 種類
- `feat`: 新機能追加
- `fix`: バグ修正
- `docs`: ドキュメント変更
- `refactor`: リファクタリング
- `test`: テスト追加

---

# 7. ファイルサイズ・数量の目安

| 項目 | 目安 | 理由 |
|------|------|------|
| 1スクリプトの行数 | 200行以下 | 可読性維持 |
| 1シーンのノード数 | 50個以下 | パフォーマンス |
| 1ディレクトリのファイル数 | 20個以下 | 階層整理 |
| 画像ファイルサイズ | 500KB以下 | ロード時間 |

---

# 8. 拡張時のディレクトリ追加ルール

## 新しいカテゴリ追加時
1. `scenes/` と `scripts/` に対称的にディレクトリ作成
2. READMEを追加（必要に応じて）

### 例: ボス戦追加
```
scenes/bosses/
├── boss_1.tscn
└── boss_2.tscn

scripts/bosses/
├── boss.gd  (基底クラス)
├── boss_1.gd
└── boss_2.gd
```

---

# 9. ドキュメントとコードの同期

## 原則
- **コード変更時**: ドキュメント更新を確認
- **設計変更時**: `docs/` の永続的ドキュメント更新
- **作業開始時**: `.steering/` に作業ドキュメント作成

## 更新フロー
1. `.steering/[日付]-[タイトル]/requirements.md` 作成
2. 設計に影響ある場合 → `docs/` 更新
3. 実装
4. `.steering/[日付]-[タイトル]/tasklist.md` 完了マーク

---

# 10. ディレクトリ構造の検証

## 検証スクリプト（将来的）
```bash
#!/bin/bash
# scripts/validate_structure.sh

# scenes/ と scripts/ の対称性チェック
# Autoload数が3つ以下かチェック
# .tscn がテキスト形式かチェック
```

---

# 11. 変更履歴

## 2026-02-26: architecture.mdとの整合性修正

### 追加されたディレクトリ
1. **scripts/items/** - exp_orb.gdの配置先（scenes/items/に対応）
2. **scripts/debug/** - performance_monitor.gdの配置先（将来的）
3. **addons/** - Godotプラグインシステム用（将来的）
4. **mods/** - ユーザーMod配置用（将来的）
5. **build/** - ビルド成果物出力先（.gitignore対象）

### 修正されたセクション
- **2.2 autoload/**: 将来的な拡張（Logger）についての記載追加
- **2.5 scripts/**: items/とdebug/サブディレクトリ追加
- **4.2 .gitignore**: mods/ディレクトリの除外設定追加

### 新規追加されたセクション
- **2.9 addons/**: プラグインアーキテクチャの説明
- **2.10 mods/**: Mod対応の説明
- **2.11 build/**: ビルド成果物の管理方針

---

**リポジトリ構造確定**: 全ディレクトリの役割とルールを定義済み（architecture.mdと整合性確保）
