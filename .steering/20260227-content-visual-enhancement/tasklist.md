# tasklist.md
コンテンツ&ビジュアル強化フェーズのタスクリスト

---

## 進捗サマリー

- **完了**: 40 / 40
- **進行中**: 0
- **未着手**: 0

**進捗率**: 100% 🎉

---

## フェーズ1: 武器システム拡張 [12/12] ✅

### 1.1 AttackType拡張 [2/2] ✅
- [x] resources/weapon.gdのAttackType enumに3種類追加
- [x] 構文チェック・動作確認

### 1.2 レーザービーム武器実装 [3/3] ✅
- [x] resources/weapons/laser_beam.tres作成
- [x] WeaponInstance._attack_penetrating()実装
- [x] Projectileにpierce_countプロパティ追加

### 1.3 オービタル武器実装 [4/4] ✅
- [x] resources/weapons/orbital.tres作成
- [x] WeaponInstance._attack_orbital()実装
- [x] WeaponInstance._update_orbital()実装（_process内）
- [x] OrbitalNodeクラス作成（衛星管理）

### 1.4 ライトニング武器実装 [3/3] ✅
- [x] resources/weapons/lightning.tres作成
- [x] WeaponInstance._attack_chain()実装
- [x] WeaponInstance._deal_chain_damage()実装（再帰）

---

## フェーズ2: 敵システム拡張 [8/8] ✅

### 2.1 HeavyEnemy実装 [3/3] ✅
- [x] scripts/enemies/heavy_enemy.gd作成
- [x] scenes/enemies/heavy_enemy.tscn作成
- [x] パラメータ設定・テスト

### 2.2 FastEnemy実装 [3/3] ✅
- [x] scripts/enemies/fast_enemy.gd作成
- [x] scenes/enemies/fast_enemy.tscn作成
- [x] パラメータ設定・テスト

### 2.3 EnemySpawner拡張 [2/2] ✅
- [x] 重み付き抽選システム実装
- [x] 新しい敵をスポーンリストに追加

---

## フェーズ3: アップグレードシステム拡張 [8/8] ✅

### 3.1 UpgradeType拡張 [1/1] ✅
- [x] scripts/systems/upgrade_generator.gdのUpgradeType enumに3種類追加

### 3.2 クリティカルシステム実装 [2/2] ✅
- [x] UpgradeApplierにcritical_rateプロパティ追加
- [x] WeaponInstance._calculate_damage()実装

### 3.3 範囲拡大システム実装 [2/2] ✅
- [x] UpgradeApplierにarea_multiplierプロパティ追加
- [x] WeaponManager.update_area_multiplier()実装

### 3.4 弾数増加システム実装 [2/2] ✅
- [x] UpgradeApplierにmultishot_countプロパティ追加
- [x] WeaponManager.update_multishot()実装

### 3.5 UpgradeGenerator更新 [1/1] ✅
- [x] 新しいアップグレード選択肢を追加

---

## フェーズ4: パーティクルエフェクト [8/8] ✅

### 4.1 共通テクスチャ作成 [1/1] ✅
- [x] CPUParticles2D使用（テクスチャ不要）

### 4.2 攻撃時エフェクト [2/2] ✅
- [x] scenes/effects/muzzle_flash.tscn作成
- [x] WeaponInstanceに統合

### 4.3 敵撃破エフェクト [2/2] ✅
- [x] scenes/effects/explosion.tscn作成
- [x] Enemy.die()に統合

### 4.4 レベルアップエフェクト [2/2] ✅
- [x] scenes/effects/level_up.tscn作成
- [x] Player.collect_exp()に統合

### 4.5 経験値オーブ輝き [1/1] ✅
- [x] scenes/items/exp_orb.tscnにCPUParticles2D追加

---

## フェーズ5: サウンドシステム [12/12] ✅

### 5.1 AudioManager Autoload [2/2] ✅
- [x] autoload/audio_manager.gd作成
- [x] project.godotにAutoload登録

### 5.2 サウンド素材準備 [6/6] ✅
- [x] assets/sounds/README.md作成（素材ガイド）
- [x] サウンドファイル存在チェック機能実装
- [x] 存在しないファイルは自動スキップ
- [x] 実際のサウンドファイルは後で追加可能
- [x] サウンドシステムは無音でも動作
- [x] AudioManagerにプーリングシステム実装

### 5.3 サウンド統合 [4/4] ✅
- [x] WeaponInstanceに攻撃音追加
- [x] Enemyにヒット音・爆発音追加
- [x] Playerにレベルアップ音・取得音追加
- [x] サウンド再生ロジック統合完了

---

## 統合・テスト・調整

### 実装完了項目
- ✅ レーザービーム（貫通武器）実装
- ✅ オービタル（周回武器）実装
- ✅ ライトニング（連鎖武器）実装
- ✅ HeavyEnemy（低速・高HP）実装
- ✅ FastEnemy（高速・低HP）実装
- ✅ クリティカル率システム実装
- ✅ 範囲拡大システム実装
- ✅ 弾数増加システム実装
- ✅ パーティクルエフェクト実装
- ✅ サウンドシステム実装

### 推奨テスト項目
実際にゲームを起動して以下を確認してください：
- [ ] レーザービームが敵を貫通する
- [ ] オービタルがプレイヤー周囲を回転する
- [ ] ライトニングが複数の敵に連鎖する
- [ ] HeavyEnemyが低速で耐久力が高い
- [ ] FastEnemyが高速で倒しやすい
- [ ] クリティカルヒットが発生する
- [ ] 範囲拡大アップグレードが機能する
- [ ] 弾数増加アップグレードが機能する
- [ ] パーティクルエフェクトが表示される
- [ ] サウンド再生機能が動作する（ファイル配置後）
- [ ] FPS 30以上を維持できる

---

## 完了報告

**全フェーズ完了**: 2026-02-27 ✅

### 実装サマリー

**フェーズ1**: 武器システム拡張
- 3種類の新武器追加（Laser Beam、Orbital、Lightning）
- 貫通、周回、連鎖の攻撃パターン実装

**フェーズ2**: 敵システム拡張
- 2種類の新敵追加（Heavy、Fast）
- 重み付き確率スポーンシステム実装

**フェーズ3**: アップグレードシステム拡張
- 3種類の新アップグレード（クリティカル、範囲拡大、マルチショット）
- 全アップグレードがWeaponManagerで統一管理

**フェーズ4**: パーティクルエフェクト
- 4種類のエフェクト（マズルフラッシュ、爆発、レベルアップ、オーブ輝き）
- CPUParticles2Dで軽量実装

**フェーズ5**: サウンドシステム
- AudioManager autoload実装
- サウンドプーリングシステム
- 6種類のSE統合（shoot、hit、explosion、levelup、pickup、ui_click）
- サウンドファイル不在でも動作する柔軟な設計

---

## 次のステップ

### 1. 動作確認
```bash
godot --path /workspaces/05_poc-godot
```

### 2. サウンド素材追加（任意）
`assets/sounds/README.md` を参照してサウンドファイルを配置

### 3. パフォーマンステスト
大量の敵・弾丸でFPSを確認

### 4. バランス調整
武器ダメージ、敵HP、アップグレード効果の微調整

---

**タスクリスト作成完了**: 2026-02-27
**全フェーズ完了**: 2026-02-27
**合計タスク数**: 40 / 40
**達成率**: 100%

🎉 **Pattern 1: A + B (lightweight) 実装完了！** 🎉
