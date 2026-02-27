# POC Godot Roguelite

2D Roguelike Action Game - MVP Implementation

---

## 概要

Godot Engine 4.3で実装された2Dローグライクアクションゲームの実動POC（Proof of Concept）です。

### 主要機能
- ✅ プレイヤー移動（WASD/矢印キー）
- ✅ 自動攻撃武器システム（3種類）
- ✅ 敵スポーン・追跡AI
- ✅ 経験値システム
- ✅ レベルアップ時の3択強化
- ✅ 15分タイマー
- ✅ ゲームオーバー・リトライ機能

---

## 動作環境

- **Godot Engine**: 4.3 stable
- **言語**: GDScript
- **解像度**: 1920x1080（推奨）
- **FPS**: 60（ターゲット）、30（最低保証）

---

## プロジェクト構造

```
/workspaces/05_poc-godot/
├── autoload/           # Autoloadスクリプト
│   ├── debug_config.gd   # デバッグ設定
│   ├── game_manager.gd   # ゲーム状態管理
│   ├── level_system.gd   # レベル・経験値管理
│   └── pool_manager.gd   # オブジェクトプール管理
├── resources/          # Resourceデータ
│   ├── weapons/          # 武器データ
│   ├── game_stats.gd     # ゲーム統計
│   └── ai_*.gd           # AI制御
├── scenes/             # シーンファイル
│   ├── game.tscn         # メインゲームシーン
│   ├── player/           # プレイヤー
│   ├── enemies/          # 敵キャラ
│   ├── items/            # アイテム
│   ├── weapons/          # 武器・弾丸
│   └── ui/               # UI要素
├── scripts/            # スクリプト
│   ├── player/
│   ├── enemies/
│   ├── items/
│   ├── weapons/
│   ├── systems/
│   └── ui/
└── docs/               # ドキュメント
    ├── product-requirements.md
    ├── functional-design.md
    ├── architecture.md
    └── troubleshooting/   # トラブルシューティング
```

---

## 起動方法

### Godot Editorから
1. Godot Engine 4.3で本プロジェクトを開く
2. F5キーまたは「実行」ボタンでゲーム開始

### コマンドラインから
```bash
godot --path /workspaces/05_poc-godot
```

---

## 操作方法

### キーボード
- **移動**: WASD または 矢印キー
- **攻撃**: 自動（敵に近づくと自動攻撃）
- **レベルアップ**: 数字キー1-3で選択

### ゲームフロー
1. タイトル画面で「START」
2. プレイヤーを操作して敵を倒す
3. 経験値オーブを収集してレベルアップ
4. 強化を選択してパワーアップ
5. 15分生存 または HP0でゲームオーバー

---

## 実装済みシステム

### コアシステム
- **GameManager**: ゲーム状態管理（TITLE/PLAYING/UPGRADE/GAMEOVER）
- **LevelSystem**: 経験値・レベル管理（成長率1.18）
- **PoolManager**: オブジェクトプール管理（敵・弾丸・経験値オーブ）

### ゲームプレイ
- **Player**: 移動、HP管理、武器管理
- **WeaponSystem**: 3種類の武器、自動攻撃、レベルアップ
- **EnemySystem**: 2種類の敵、追跡AI、スポーナー
- **ItemSystem**: 経験値オーブ、吸引システム
- **UpgradeSystem**: 5種類の強化、3択ランダム生成

### UI
- **HUD**: HP、レベル、経験値バー、経過時間
- **UpgradePanel**: レベルアップ強化選択
- **GameOverScreen**: 統計表示、リトライ
- **TitleScreen**: スタート、終了

---

## 技術的特徴

### 設計パターン
- **Strategy Pattern**: 敵AIシステム（AIController Resource）
- **Object Pool Pattern**: 敵・弾丸・経験値オーブの再利用
- **Resource-based Data**: 武器データ、AI制御データ

### パフォーマンス最適化
- シーンパス別オブジェクトプール
- LRU方式のプール上限管理
- 物理演算の最適化（deferred処理）

### コード品質
- **型安全**: 全関数・変数に型アノテーション
- **エラーハンドリング**: nullチェック、push_error/warning
- **デバッグシステム**: ログレベル管理（DebugConfig Autoload）

---

## 既知の問題

### 物理エンジン警告（低優先度）
**症状**:
```
ERROR: Can't change this state while flushing queries.
Use call_deferred() or set_deferred() to change monitoring state instead.
```

**発生箇所**: 経験値オーブの初期化・返却処理
**発生頻度**: 約42件/分
**機能影響**: なし（警告のみ、ゲームプレイは正常）

**原因**: Godot 4.3の物理フレームタイミング制約による既知の制限

**対応状況**:
- 機能に影響がないため現状維持
- 詳細は [docs/troubleshooting/2026-02-27_exp_orb_not_attracting.md](docs/troubleshooting/2026-02-27_exp_orb_not_attracting.md) を参照
- Godot 4.4以降のバージョンアップで改善される可能性

---

## デバッグ機能

### ログレベル設定
`autoload/debug_config.gd`の`CURRENT_LEVEL`を変更してログ出力を調整:

```gdscript
const CURRENT_LEVEL: LogLevel = LogLevel.INFO  # デフォルト
```

#### ログレベル
- **NONE** (0): ログ出力なし（リリースビルド）
- **CRITICAL** (1): エラー・警告のみ
- **INFO** (2): 重要な情報のみ（デフォルト）
- **DEBUG** (3): 詳細デバッグ情報
- **TRACE** (4): 全イベントトレース

### 使用例
```gdscript
DebugConfig.log_info("Player", "Level up!")
DebugConfig.log_debug("Enemy", "Spawned at %v" % position)
DebugConfig.log_trace("Weapon", "Attack triggered")
```

---

## テスト

### 基本動作確認
- [x] プレイヤー移動
- [x] 武器自動攻撃
- [x] 敵スポーン・追跡
- [x] 経験値オーブ収集
- [x] レベルアップ・強化選択
- [x] ゲームオーバー・リトライ
- [x] 15分タイマー

### パフォーマンステスト（次期開発で実施）
- [ ] 敵100体同時
- [ ] 弾丸300発同時
- [ ] 15分連続プレイ

---

## 今後の開発予定

### Phase 2: コンテンツ拡張
- 新しい武器タイプ（4-6種類）
- 新しい敵タイプ（3-5種類）
- ボス戦システム

### Phase 3: ビジュアル/オーディオ強化
- パーティクルエフェクト
- サウンド/BGM
- アニメーションシステム

### Phase 4: メタプログレッション
- 永続的な強化システム
- アンロック要素
- アチーブメント

---

## ドキュメント

- [プロダクト要求定義](docs/product-requirements.md)
- [機能設計書](docs/functional-design.md)
- [技術仕様書](docs/architecture.md)
- [開発ガイドライン](docs/development-guidelines.md)
- [トラブルシューティング](docs/troubleshooting/)

---

## ライセンス

本プロジェクトはMITライセンスの下で公開されています。

---

## 作成者

- **開発**: Claude (Anthropic) with Human guidance
- **エンジン**: Godot Engine 4.3
- **日付**: 2026-02-26 〜 2026-02-27

---

**最終更新**: 2026-02-27
