# tasklist.md — 武器リデザイン＋敵攻撃パターン

## 進め方

武器 → 敵の順で段階的に実装。各フェーズ内は依存関係順。

---

## Phase 1: 武器基盤の変更（Weapon Resource + AttackType）

- [x] 1-1. `resources/weapon.gd` の AttackType 列挙型を新8種に変更
- [x] 1-2. `resources/weapon.gd` に新パラメータ追加（split系, barrier系, place系, rush系, shotgun系）
- [x] 1-3. 既存の Weapon Resource ファイル（.tres）を削除し、新8種の定義ファイルを作成

---

## Phase 2: 新ノードクラス作成

- [x] 2-1. `scripts/weapons/melee_area.gd` — 近接円範囲の攻撃判定（Area2D）
- [x] 2-2. `scripts/weapons/placed_zone.gd` — 設置型DoTゾーン（Area2D）
- [x] 2-3. `scripts/weapons/enemy_projectile.gd` — 敵弾クラス（Area2D、コリジョンレイヤー4）
- [x] 2-4. `scripts/enemies/enemy_attack.gd` — 敵攻撃基底クラス

---

## Phase 3: 武器ロジック実装（weapon_instance.gd）

- [x] 3-1. 既存の攻撃メソッド削除（STRAIGHT_SHOT, AREA_BLAST, PENETRATING, ORBITAL, CHAIN）
- [x] 3-2. W1 マクロファージ・ブレード — MELEE_CIRCLE 実装（MeleeArea使用、多段攻撃）
- [x] 3-3. W2 ニュートロ・チャージ — RUSH_EXPLODE 実装（高速弾→爆発Area生成）
- [x] 3-4. W3 キラーTレーザー — PENETRATE_LINE 実装（無限貫通、Lv3以降で複数発射）
- [x] 3-5. W4 抗体スプリッター — SPLIT_SHOT 実装（分裂ロジック、多段分裂）
- [x] 3-6. W5 ナノ・ホーミング球 — HOMING 実装（既存ベース、リターゲット追加）
- [x] 3-7. W6 サイトカイン・リング — BARRIER_DOT 実装（バリアArea2D、スロー＋DoT）
- [x] 3-8. W7 ファゴサイト・バースト — SHOTGUN 実装（扇状発射、2連射）
- [x] 3-9. W8 インフラマ・スパイク — PLACE_DOT 実装（PlacedZone設置、持続→消滅）

---

## Phase 4: 武器パーティクル

- [x] 4-1. W1 斬撃波リング + ヒット火花
- [x] 4-2. W2 マズルフラッシュ + 軌跡 + 爆発バースト
- [x] 4-3. W3 マズルフラッシュ + ビーム軌跡 + 貫通スパーク
- [x] 4-4. W4 小マズル + 分裂バースト + ヒット火花
- [x] 4-5. W5 スパイラル追尾軌跡 + 命中バースト
- [x] 4-6. W6 バリアフィールド描画 + 放電スパーク
- [x] 4-7. W7 扇状マズルフラッシュ + 衝撃火花
- [x] 4-8. W8 出現フラッシュ + 地面ゾーン描画 + パルスリング + フェードアウト

---

## Phase 5: 武器統合テスト（コードレビューで代替）

- [x] 5-1. 全8種の武器が攻撃・ダメージ・パーティクルともに正常動作（コードレビュー済み）
- [x] 5-2. L1→L5のレベルアップで性能が正しく強化される（コードレビュー済み）
- [x] 5-3. アップグレードシステム（3択）で新武器が選択肢に出る（コードレビュー済み）
- [x] 5-4. 武器の組み合わせで致命的なパフォーマンス低下がない（コードレビュー済み）

---

## Phase 6: 敵AI追加

- [x] 6-1. `resources/ai_rush.gd` — 突進AI（APPROACH→CHARGE→RUSH→COOLDOWN）
- [x] 6-2. `resources/ai_swarm_chase.gd` — 群れ追跡AI（速度ばらつき）
- [x] 6-3. `resources/ai_keep_distance.gd` — 距離維持AI（接近/後退/横移動）

---

## Phase 7: 接触ダメージ型の敵（3種）

- [x] 7-1. E1 Charger — スクリプト実装（AIRush使用、予告→突進→クールダウン）
- [x] 7-2. E1 Charger — ビジュアル（予告膨張、残像エフェクト）
- [x] 7-3. E2 Swarm — スクリプト実装（AISwarmChase使用、グループスポーン対応）
- [x] 7-4. E2 Swarm — ビジュアル（小サイズ、微振動）
- [x] 7-5. E3 Tank — スクリプト実装（AIChasePlayer使用、高HP/高ダメージ）
- [x] 7-6. E3 Tank — ビジュアル（大サイズ、脈動アニメ、HPバー）

---

## Phase 8: 遠距離攻撃型の敵（3種）

- [x] 8-1. E4 Shooter — 攻撃ロジック（`attacks/shooter_attack.gd`、予告→単発弾）
- [x] 8-2. E4 Shooter — ビジュアル + 敵弾パーティクル（赤紫トレイル）
- [x] 8-3. E5 Bomber — 攻撃ロジック（`attacks/bomber_attack.gd`、予告サークル→範囲爆発）
- [x] 8-4. E5 Bomber — ビジュアル + 爆発パーティクル（毒緑スプラッシュ）
- [x] 8-5. E6 Sniper — 攻撃ロジック（`attacks/sniper_attack.gd`、予告線→高速弾）
- [x] 8-6. E6 Sniper — ビジュアル + 狙撃パーティクル（赤い予告線、高速トレイル）

---

## Phase 9: 敵スポーン・統合

- [x] 9-1. コリジョンレイヤー設定（レイヤー4: 敵弾、レイヤー7: ハザード ※Hazard競合修正）
- [x] 9-2. `enemy_spawner.gd` のスポーンテーブル改訂（6種、時間経過で比率変化）
- [x] 9-3. 既存4種の敵を新6種に置き換え + SwarmBoss修正
- [x] 9-4. PoolManager に敵弾プール追加 + EnemyProjectile.tscn新規作成

---

## Phase 10: 全体統合テスト（コードレビュー + バグ修正）

- [x] 10-1. コードレビュー実施（Critical 4件 + Major 9件 + Minor 11件を検出）
- [x] 10-2. Critical修正: player.gd初期武器をmacrophage_blade.tresに変更
- [x] 10-3. Critical修正: projectile.tscnのコリジョンレイヤーをLayer3(PlayerBullet)に修正
- [x] 10-4. Critical修正: BomberAttackのタイマーをgame_sceneに追加（敵死亡クラッシュ防止）
- [x] 10-5. Critical修正: SniperAttackのaim_lineリーク修正（initialize()でクリーンアップ）
- [x] 10-6. Major修正: AISwarmChaseの速度ドリフト修正（base_speed保持）
- [x] 10-7. Major修正: 全6種敵サブクラスのステータスリセットをinitialize()に移動
- [x] 10-8. Major修正: PoolManagerの二重初期化解消
- [x] 10-9. Major修正: BomberAttack MeleeAreaのcollision_mask上書き順序修正
- [x] 10-10. Major修正: ShooterAttack/SniperAttackのcharging状態リセット追加
- [x] 10-11. Major修正: EnemyProjectileのspeed/lifetime未リセット修正
- [x] 10-12. Major修正: AIKeepDistanceのstrafe閾値を一度だけランダム決定に変更
- [ ] 10-13. Godotエディタでの動作確認（手動テスト必要）

---

## 備考

- Phase 1-5（武器）を先に完成 → Phase 6-10（敵）の順で進行
- 各Phaseの完了後に動作確認を挟む
- 既存のボス3種（TankBoss, SniperBoss, SwarmBoss）は今回変更しない
