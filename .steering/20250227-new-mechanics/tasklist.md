# フェーズC: 新メカニクス導入 - タスクリスト

**作成日**: 2026-02-27
**フェーズ**: C (New Mechanics)

---

## タスク概要

全56タスク（5つのメカニクス × 各サブタスク + UI + テスト）

---

## 1. コンボシステム（8タスク）

### 1.1 ComboManager実装
- [ ] `autoload/combo_manager.gd` 作成
- [ ] シグナル定義（combo_increased, combo_broken, combo_multiplier_changed）
- [ ] コンボ加算ロジック実装
- [ ] タイムアウトロジック実装
- [ ] 経験値倍率計算ロジック実装

### 1.2 既存システムとの統合
- [ ] `Enemy.gd`の`_die()`にコンボ加算を追加
- [ ] 経験値オーブ生成時にコンボボーナスを適用

### 1.3 UI実装
- [ ] `scenes/ui/combo_display.tscn` 作成
- [ ] `scripts/ui/combo_display.gd` 実装（コンボ数表示、タイマーゲージ）
- [ ] HUDにComboDisplayを追加
- [ ] コンボ数に応じた色変化実装（10+: 金色、50+: 虹色）

### 1.4 エフェクトと音
- [ ] コンボ更新時のポップアップアニメーション
- [ ] コンボ途切れ時のフェードアウト演出
- [ ] コンボ音（ビープ音の高さで表現）

---

## 2. パワーアップアイテム（12タスク）

### 2.1 PowerUpManager実装
- [ ] `autoload/powerup_manager.gd` 作成
- [ ] PowerUpType enum定義（5種類）
- [ ] スポーンタイマー実装
- [ ] ランダム位置生成ロジック（プレイヤーから100px以上離れた場所）
- [ ] apply_powerup()実装（各タイプの効果適用）
- [ ] Screen Clearロジック実装（全敵撃破）

### 2.2 PowerUpアイテム実装
- [ ] `scenes/items/powerup.tscn` 作成
- [ ] `scripts/items/powerup.gd` 実装
- [ ] タイプ別の色設定
- [ ] GlowParticles追加
- [ ] lifetime管理（10秒後に消える）
- [ ] 消える直前の点滅エフェクト
- [ ] 拾った時のSEとエフェクト

### 2.3 Playerへの拡張
- [ ] `Player.gd`に`active_powerups`辞書追加
- [ ] `add_powerup_effect()`メソッド実装
- [ ] `has_powerup()`メソッド実装
- [ ] パワーアップ時間管理（_process内）
- [ ] Invincibility適用（take_damage修正）
- [ ] Double Damage適用（WeaponManagerに伝播）
- [ ] Speed Boost適用（move_speed倍率）
- [ ] Magnet適用（attract_range倍率）

### 2.4 視覚エフェクト
- [ ] パワーアップごとのオーラエフェクト（CPUParticles2D）
- [ ] 無敵時の黄色いオーラ
- [ ] 攻撃力2倍時の赤いオーラ
- [ ] 速度2倍時の青い残像

### 2.5 UI実装
- [ ] `scenes/ui/powerup_timer_display.tscn` 作成
- [ ] `scripts/ui/powerup_timer_display.gd` 実装
- [ ] アクティブなパワーアップのアイコン一覧表示
- [ ] 各パワーアップの残り時間表示

---

## 3. 環境ハザード（10タスク）

### 3.1 HazardManager実装
- [ ] `autoload/hazard_manager.gd` 作成
- [ ] HazardType enum定義（4種類）
- [ ] スポーンタイマー実装（20秒ごと）
- [ ] 安全な位置生成ロジック

### 3.2 Hazard基本実装
- [ ] `scenes/hazards/hazard.tscn` 作成（Area2D）
- [ ] `scripts/hazards/hazard.gd` 実装
- [ ] 警告フェーズ実装（1秒間）
- [ ] アクティブフェーズ実装
- [ ] タイプ別の色とパーティクル設定

### 3.3 各ハザードタイプの実装
- [ ] Lava Pool: 継続ダメージ（毎秒10）、8秒持続
- [ ] Poison Cloud: 継続ダメージ（毎秒5）、12秒持続
- [ ] Lightning Strike: 一撃100ダメージ、即座発動
- [ ] Ice Patch: 移動速度50%減少、10秒持続

### 3.4 衝突判定
- [ ] body_entered/body_exited処理
- [ ] bodies_in_hazard配列管理
- [ ] 継続ダメージ処理（_process内）
- [ ] 氷床の移動速度減少処理

### 3.5 エフェクトと音
- [ ] 警告時の半透明ビジュアル
- [ ] アクティブ時のパーティクル
- [ ] 発動時のSE

---

## 4. プレイヤー特殊能力（10タスク）

### 4.1 SkillManager実装
- [ ] `scripts/player/skill_manager.gd` 作成（Playerの子ノード）
- [ ] SkillType enum定義（4種類）
- [ ] 選択されたスキルの保持
- [ ] クールダウン管理
- [ ] シグナル定義（skill_used, cooldown_started, cooldown_updated）

### 4.2 入力処理
- [ ] `project.godot`に"use_skill"アクション追加（Space）
- [ ] _unhandled_input()でスキル発動
- [ ] クールダウン中は発動不可

### 4.3 各スキルの実装
- [ ] Dash: Tween移動 + 0.3秒無敵
- [ ] Nova Blast: 範囲200pxの敵にダメージ100
- [ ] Shield: 3秒間無敵 + シールドエフェクト
- [ ] Time Slow: 5秒間敵の速度50%減少

### 4.4 視覚エフェクト
- [ ] Dashの残像エフェクト
- [ ] Nova Blastの爆発エフェクト（大きめ）
- [ ] Shieldのバリアビジュアル（Playerに円形追加）
- [ ] Time Slowの画面全体青みがかるエフェクト

### 4.5 UI実装
- [ ] `scenes/ui/skill_cooldown_display.tscn` 作成
- [ ] `scripts/ui/skill_cooldown_display.gd` 実装
- [ ] スキルアイコン表示
- [ ] クールダウンゲージ表示（円形または線形）
- [ ] 使用不可時のグレーアウト

### 4.6 スキル選択画面（簡易版）
- [ ] `scenes/ui/skill_selection_screen.tscn` 作成
- [ ] ゲーム開始前にスキル選択
- [ ] 4つのスキルボタン
- [ ] 選択したスキルをSkillManagerに設定

---

## 5. ボスバトルシステム（18タスク）

### 5.1 BossManager実装
- [ ] `autoload/boss_manager.gd` 作成
- [ ] シグナル定義（boss_spawned, boss_defeated, boss_health_changed）
- [ ] ボススポーンタイマー実装（180秒 = 3分）
- [ ] ボスシーン配列のロード
- [ ] ランダムボス選択とインスタンス化
- [ ] 画面端からのスポーン位置計算
- [ ] ボスのhealth_changed/diedシグナル接続

### 5.2 Boss基底クラス実装
- [ ] `scripts/bosses/boss.gd` 作成（extends CharacterBody2D）
- [ ] シグナル定義（health_changed, died）
- [ ] HP管理
- [ ] フェーズ管理（current_phase）
- [ ] take_damage()実装
- [ ] _enter_phase_2()実装（HP 50%でトリガー）
- [ ] _die()実装（経験値オーブ大量ドロップ）

### 5.3 TankBoss実装
- [ ] `scenes/bosses/tank_boss.tscn` 作成
- [ ] `scripts/bosses/tank_boss.gd` 実装
- [ ] プレイヤーへの移動ロジック
- [ ] 攻撃タイマー（3秒ごと）
- [ ] _attack_shockwave()実装（360度12方向に弾）
- [ ] _attack_barrage()実装（プレイヤー方向に3連射）
- [ ] フェーズ2移行時の変化（色変更、速度低下）

### 5.4 SniperBoss実装
- [ ] `scenes/bosses/sniper_boss.tscn` 作成
- [ ] `scripts/bosses/sniper_boss.gd` 実装
- [ ] プレイヤーから距離を保つ移動ロジック
- [ ] 攻撃タイマー（2秒ごと）
- [ ] _attack_snipe()実装（プレイヤー狙撃）
- [ ] _attack_triple_snipe()実装（3方向同時狙撃）
- [ ] 高速弾の実装

### 5.5 SwarmBoss実装
- [ ] `scenes/bosses/swarm_boss.tscn` 作成
- [ ] `scripts/bosses/swarm_boss.gd` 実装
- [ ] プレイヤーへの低速移動
- [ ] 召喚タイマー（5秒ごと）
- [ ] _summon_minions()実装（3体 → フェーズ2で5体）
- [ ] 召喚された敵の色変更（マゼンタ）

### 5.6 ボス弾の実装
- [ ] ボス専用のプロジェクタイル（色、速度、ダメージ）
- [ ] PoolManagerにボス弾プール追加
- [ ] プレイヤーへのダメージ処理

### 5.7 UI実装
- [ ] `scenes/ui/boss_health_bar.tscn` 作成
- [ ] `scripts/ui/boss_health_bar.gd` 実装
- [ ] ボス名表示
- [ ] HPバー（ProgressBar）
- [ ] ボス出現時にshow()、撃破時にhide()
- [ ] HUDにBossHealthBarを追加

### 5.8 エフェクトと音
- [ ] ボス出現時のSE（低い警告音）
- [ ] ボス撃破時のSE（勝利音）
- [ ] ボスの攻撃時のSE

---

## 6. プロジェクト設定（3タスク）

- [ ] `project.godot`にBossManager autoload追加
- [ ] `project.godot`にPowerUpManager autoload追加
- [ ] `project.godot`にHazardManager autoload追加
- [ ] `project.godot`にComboManager autoload追加
- [ ] `project.godot`に"use_skill"入力アクション追加

---

## 7. 統合とテスト（5タスク）

### 7.1 統合
- [ ] 全ての新AutoLoadをGameに統合
- [ ] HUDに全ての新UI要素を配置
- [ ] PlayerにSkillManager子ノード追加

### 7.2 動作確認
- [ ] コンボシステム動作テスト
- [ ] パワーアップ取得とタイマーテスト
- [ ] ハザード出現と警告テスト
- [ ] スキル発動とクールダウンテスト
- [ ] ボス出現と戦闘テスト

### 7.3 バランス調整
- [ ] ボスのHP/ダメージ調整
- [ ] パワーアップ出現頻度調整
- [ ] ハザード出現頻度調整
- [ ] スキルクールダウン時間調整

### 7.4 パフォーマンステスト
- [ ] ボス戦中のFPS測定
- [ ] 全メカニクス同時稼働時のFPS測定
- [ ] 必要に応じて最適化

### 7.5 最終確認
- [ ] 全ての受け入れ条件を満たしているか確認
- [ ] バグがないか確認
- [ ] ゲームプレイが楽しいか確認

---

## 実装順序（推奨）

### Week 1: 基礎システム（簡単なものから）
1. コンボシステム（1-2時間）
2. パワーアップアイテム（2-3時間）
3. 環境ハザード（2-3時間）

### Week 2: プレイヤー拡張
4. プレイヤー特殊能力（3-4時間）
5. スキル選択画面（1時間）

### Week 3: ボスシステム（最も複雑）
6. BossManagerとBoss基底クラス（2時間）
7. TankBoss（1-2時間）
8. SniperBoss（1-2時間）
9. SwarmBoss（1-2時間）
10. ボスUI（1時間）

### Week 4: 統合と調整
11. 全システム統合（1時間）
12. バランス調整（2-3時間）
13. パフォーマンステスト（1時間）
14. 最終確認（1時間）

**総見積もり（AI支援）**: 1-1.5日

---

## 完了条件

- [ ] 全56タスクが完了している
- [ ] 全ての受け入れ条件を満たしている
- [ ] FPS 60を維持している
- [ ] バグがない
- [ ] ゲームプレイが楽しい

---

## 次のステップ

承認後、実装を開始します。
実装は上記の順序で進め、各セクション完了ごとに動作確認を行います。
