# design.md
コンテンツ&ビジュアル強化フェーズの設計

---

## 設計概要

**目的**: 既存システムを活用しつつ、新しいコンテンツとビジュアルエフェクトを追加

**アプローチ**:
- 既存のアーキテクチャを維持
- Resource/Strategyパターンの継続使用
- 段階的な追加（既存機能を壊さない）

---

## A. コンテンツ拡張の設計

### 1. 新しい武器の設計

#### 1.1 AttackType Enumの拡張

**現在**:
```gdscript
enum AttackType {
	STRAIGHT_SHOT,   # 直線弾
	AREA_BLAST,      # 範囲爆発
	HOMING_MISSILE   # ホーミングミサイル
}
```

**拡張後**:
```gdscript
enum AttackType {
	STRAIGHT_SHOT,   # 直線弾
	AREA_BLAST,      # 範囲爆発
	HOMING_MISSILE,  # ホーミングミサイル
	PENETRATING,     # 貫通弾（レーザービーム）
	ORBITAL,         # 周囲回転（オービタル）
	CHAIN            # 連鎖攻撃（ライトニング）
}
```

#### 1.2 Weapon Resource定義

##### レーザービーム (laser_beam.tres)
```gdscript
[resource]
weapon_name = "Laser Beam"
display_name = "レーザービーム"
description = "敵を貫通する赤いレーザー"
attack_type = AttackType.PENETRATING
base_damage = 8
base_attack_speed = 0.6
max_level = 5
projectile_speed = 800.0
projectile_lifetime = 2.0
pierce_count = -1  # 無限貫通
projectile_color = Color(1.0, 0.2, 0.2, 1.0)  # 赤
```

##### オービタル (orbital.tres)
```gdscript
[resource]
weapon_name = "Orbital"
display_name = "オービタル"
description = "周囲を回る衛星が敵を攻撃"
attack_type = AttackType.ORBITAL
base_damage = 15
base_attack_speed = 0.0  # 継続攻撃
max_level = 5
orbital_radius = 80.0
orbital_speed = 2.0  # 回転速度（rad/s）
orbital_count = 1  # 衛星の数（レベルアップで増加）
projectile_color = Color(0.2, 0.5, 1.0, 1.0)  # 青
```

##### ライトニング (lightning.tres)
```gdscript
[resource]
weapon_name = "Lightning"
display_name = "ライトニング"
description = "最大3体の敵に連鎖する稲妻"
attack_type = AttackType.CHAIN
base_damage = 12
base_attack_speed = 1.2
max_level = 5
chain_range = 100.0
chain_count = 3
chain_damage_falloff = 0.8  # 連鎖ごとに80%に減衰
projectile_color = Color(1.0, 1.0, 0.2, 1.0)  # 黄色
```

#### 1.3 WeaponInstanceの拡張

**ファイル**: `scripts/player/weapon_instance.gd`

**追加メソッド**:
```gdscript
## 貫通弾攻撃
func _attack_penetrating() -> void:
	var nearest_enemy = _find_nearest_enemy()
	if nearest_enemy == null:
		return

	var direction = (nearest_enemy.global_position - owner_player.global_position).normalized()
	var projectile = PoolManager.spawn_projectile(owner_player.global_position, direction, current_damage)

	if projectile != null:
		projectile.pierce_count = -1  # 無限貫通
		projectile.lifetime = 2.0
		# パーティクル設定
		if projectile.has_node("Particles"):
			projectile.get_node("Particles").emitting = true

## オービタル攻撃（継続的に更新）
func _attack_orbital() -> void:
	# オービタル衛星の生成・更新は_process()で処理
	pass

func _update_orbital(delta: float) -> void:
	# 既存のオービタル衛星を回転
	for orbital in active_orbitals:
		orbital.angle += weapon_data.orbital_speed * delta
		var offset = Vector2(
			cos(orbital.angle) * weapon_data.orbital_radius,
			sin(orbital.angle) * weapon_data.orbital_radius
		)
		orbital.node.global_position = owner_player.global_position + offset

## 連鎖攻撃
func _attack_chain() -> void:
	var nearest_enemy = _find_nearest_enemy()
	if nearest_enemy == null:
		return

	# 最初の敵に攻撃
	_deal_chain_damage(nearest_enemy, current_damage, weapon_data.chain_count - 1, [])

func _deal_chain_damage(target: Node, damage: int, remaining_chains: int, hit_enemies: Array) -> void:
	if target == null or target in hit_enemies:
		return

	# ダメージ適用
	if target.has_method("take_damage"):
		target.take_damage(damage)

	hit_enemies.append(target)

	# 連鎖継続
	if remaining_chains > 0:
		var next_target = _find_nearest_enemy_in_range(target.global_position, weapon_data.chain_range, hit_enemies)
		if next_target != null:
			var next_damage = int(damage * weapon_data.chain_damage_falloff)
			# ビジュアルエフェクト（稲妻線）
			_draw_lightning_line(target.global_position, next_target.global_position)
			_deal_chain_damage(next_target, next_damage, remaining_chains - 1, hit_enemies)
```

---

### 2. 新しい敵の設計

#### 2.1 Enemy基底クラスの確認

**既存のEnemy基底クラス**は十分に汎用的なので、継承して使用可能。

#### 2.2 HeavyEnemy (タンク型)

**ファイル**: `scripts/enemies/heavy_enemy.gd`

```gdscript
extends Enemy
class_name HeavyEnemy

func _ready() -> void:
	super._ready()

	# パラメータ設定
	max_hp = 150
	current_hp = max_hp
	move_speed = 60
	exp_value = 10
	damage = 15  # 接触ダメージ

	# ビジュアル設定
	if has_node("Visual"):
		var visual = get_node("Visual")
		visual.size = Vector2(48, 48)
		visual.color = Color(0.8, 0.2, 0.2, 1.0)  # 濃い赤
```

**シーン**: `scenes/enemies/heavy_enemy.tscn`
- Enemy.tscnを継承
- スクリプトをheavy_enemy.gdに設定
- CollisionShape2Dのサイズを48x48に変更

#### 2.3 FastEnemy (スピード型)

**ファイル**: `scripts/enemies/fast_enemy.gd`

```gdscript
extends Enemy
class_name FastEnemy

func _ready() -> void:
	super._ready()

	# パラメータ設定
	max_hp = 15
	current_hp = max_hp
	move_speed = 150
	exp_value = 3
	damage = 5  # 接触ダメージ

	# ビジュアル設定
	if has_node("Visual"):
		var visual = get_node("Visual")
		visual.size = Vector2(16, 16)
		visual.color = Color(1.0, 1.0, 0.2, 1.0)  # 黄色
```

**シーン**: `scenes/enemies/fast_enemy.tscn`
- Enemy.tscnを継承
- スクリプトをfast_enemy.gdに設定
- CollisionShape2Dのサイズを16x16に変更

#### 2.4 EnemySpawnerの拡張

**ファイル**: `scripts/systems/enemy_spawner.gd`

**変更点**:
```gdscript
# 敵の種類リスト拡張
const ENEMY_TYPES: Array[Dictionary] = [
	{
		"scene_path": "res://scenes/enemies/basic_enemy.tscn",
		"weight": 50  # 50%
	},
	{
		"scene_path": "res://scenes/enemies/strong_enemy.tscn",
		"weight": 20  # 20%
	},
	{
		"scene_path": "res://scenes/enemies/heavy_enemy.tscn",
		"weight": 15  # 15%
	},
	{
		"scene_path": "res://scenes/enemies/fast_enemy.tscn",
		"weight": 15  # 15%
	}
]

# 重み付き抽選
func _select_random_enemy_type() -> String:
	var total_weight = 0
	for enemy_type in ENEMY_TYPES:
		total_weight += enemy_type.weight

	var rand_value = randi() % total_weight
	var cumulative_weight = 0

	for enemy_type in ENEMY_TYPES:
		cumulative_weight += enemy_type.weight
		if rand_value < cumulative_weight:
			return enemy_type.scene_path

	return ENEMY_TYPES[0].scene_path
```

---

### 3. 新しいアップグレードの設計

#### 3.1 UpgradeType Enumの拡張

**現在**:
```gdscript
enum UpgradeType {
	WEAPON_DAMAGE,
	WEAPON_ATTACK_SPEED,
	PLAYER_SPEED,
	PLAYER_MAX_HP,
	ADD_WEAPON
}
```

**拡張後**:
```gdscript
enum UpgradeType {
	WEAPON_DAMAGE,
	WEAPON_ATTACK_SPEED,
	PLAYER_SPEED,
	PLAYER_MAX_HP,
	ADD_WEAPON,
	CRITICAL_RATE,      # クリティカル率UP
	AREA_EXPANSION,     # 範囲拡大
	MULTISHOT           # 弾数増加
}
```

#### 3.2 UpgradeGeneratorの拡張

**ファイル**: `scripts/systems/upgrade_generator.gd`

**追加する選択肢定義**:
```gdscript
# クリティカル率UP
{
	"type": UpgradeType.CRITICAL_RATE,
	"display_name": "Critical Strike",
	"description": "攻撃が10%の確率で2倍ダメージ",
	"rarity": Rarity.RARE
}

# 範囲拡大
{
	"type": UpgradeType.AREA_EXPANSION,
	"display_name": "Area Expansion",
	"description": "範囲攻撃の効果範囲が20%拡大",
	"rarity": Rarity.COMMON
}

# 弾数増加
{
	"type": UpgradeType.MULTISHOT,
	"display_name": "Multishot",
	"description": "武器の発射弾数が1増加",
	"rarity": Rarity.RARE
}
```

#### 3.3 UpgradeApplierの拡張

**ファイル**: `scripts/systems/upgrade_applier.gd`

**追加する適用ロジック**:
```gdscript
# グローバル変数追加
var critical_rate: float = 0.0  # クリティカル率
var area_multiplier: float = 1.0  # 範囲倍率
var multishot_count: int = 0  # 追加弾数

func apply_upgrade(option: Dictionary) -> void:
	match option.type:
		# ... 既存のケース ...

		UpgradeType.CRITICAL_RATE:
			critical_rate = min(critical_rate + 0.1, 0.5)  # 最大50%
			DebugConfig.log_info("UpgradeApplier", "Critical rate increased to %.1f%%" % (critical_rate * 100))

		UpgradeType.AREA_EXPANSION:
			area_multiplier += 0.2
			# 全武器の範囲を更新
			if player_ref.weapon_manager != null:
				player_ref.weapon_manager.update_area_multiplier(area_multiplier)
			DebugConfig.log_info("UpgradeApplier", "Area multiplier increased to %.1f" % area_multiplier)

		UpgradeType.MULTISHOT:
			multishot_count += 1
			# 全武器の弾数を更新
			if player_ref.weapon_manager != null:
				player_ref.weapon_manager.update_multishot(multishot_count)
			DebugConfig.log_info("UpgradeApplier", "Multishot count increased to %d" % multishot_count)
```

#### 3.4 クリティカルシステムの実装

**WeaponInstanceに追加**:
```gdscript
func _calculate_damage(base_damage: int) -> int:
	var damage = base_damage

	# クリティカル判定
	if UpgradeApplier.critical_rate > 0.0:
		if randf() < UpgradeApplier.critical_rate:
			damage *= 2
			# クリティカルエフェクト表示
			_show_critical_effect()

	return damage
```

---

## B. ビジュアル/オーディオの設計

### 1. パーティクルエフェクトの設計

#### 1.1 共通パーティクル設定

**プロセスマテリアル設定**:
```gdscript
# 共通設定
amount = 20
lifetime = 0.5
explosiveness = 0.8
process_material = ParticleProcessMaterial.new()
texture = preload("res://assets/particles/circle.png")  # シンプルな円形テクスチャ
```

#### 1.2 攻撃時エフェクト

**シーン**: `scenes/effects/muzzle_flash.tscn`

**設定**:
```gdscript
# GPUParticles2D
amount = 10
lifetime = 0.2
one_shot = true
explosiveness = 1.0

# ParticleProcessMaterial
direction = Vector3(0, -1, 0)
spread = 30.0
initial_velocity_min = 50.0
initial_velocity_max = 100.0
gravity = Vector3(0, 0, 0)
scale_min = 0.5
scale_max = 1.0
color = Color(1.0, 1.0, 0.5, 1.0)  # 黄色（武器ごとに変更）
```

**使用方法**:
```gdscript
# WeaponInstance内
func _spawn_muzzle_flash() -> void:
	var flash = muzzle_flash_scene.instantiate()
	owner_player.add_child(flash)
	flash.global_position = owner_player.global_position
	flash.emitting = true
	# 0.5秒後に自動削除
	flash.finished.connect(flash.queue_free)
```

#### 1.3 敵撃破エフェクト

**シーン**: `scenes/effects/explosion.tscn`

**設定**:
```gdscript
# GPUParticles2D
amount = 30
lifetime = 0.5
one_shot = true
explosiveness = 0.8

# ParticleProcessMaterial
direction = Vector3(0, 0, 0)
spread = 180.0
initial_velocity_min = 100.0
initial_velocity_max = 200.0
gravity = Vector3(0, 200, 0)
scale_min = 1.0
scale_max = 2.0
color_ramp = Gradient.new()
# 赤 -> オレンジ -> 黄 -> 透明
```

**使用方法**:
```gdscript
# Enemy.die()内
func die() -> void:
	# エフェクト生成
	var explosion = explosion_scene.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	explosion.emitting = true

	# ... 既存の処理 ...
```

#### 1.4 レベルアップエフェクト

**シーン**: `scenes/effects/level_up.tscn`

**設定**:
```gdscript
# GPUParticles2D
amount = 50
lifetime = 1.0
one_shot = true
explosiveness = 0.5

# ParticleProcessMaterial
direction = Vector3(0, -1, 0)
spread = 180.0
initial_velocity_min = 50.0
initial_velocity_max = 150.0
gravity = Vector3(0, -100, 0)  # 上向き
scale_min = 1.0
scale_max = 3.0
color = Color(1.0, 0.9, 0.3, 1.0)  # 金色
```

**使用方法**:
```gdscript
# Player内（レベルアップ時）
func collect_exp(amount: int) -> void:
	# ... 既存の処理 ...

	if leveled_up:
		# レベルアップエフェクト
		_spawn_level_up_effect()
		# ...
```

#### 1.5 経験値オーブの輝き

**ExpOrbシーンに追加**:

**設定**:
```gdscript
# GPUParticles2D（ExpOrbの子ノード）
amount = 10
lifetime = 1.0
explosiveness = 0.0  # 継続的
preprocess = 0.5

# ParticleProcessMaterial
direction = Vector3(0, -1, 0)
spread = 180.0
initial_velocity_min = 10.0
initial_velocity_max = 30.0
gravity = Vector3(0, 0, 0)
scale_min = 0.3
scale_max = 0.8
color_ramp = Gradient.new()
# 緑 -> 黄 -> 透明
```

---

### 2. サウンドエフェクトの設計

#### 2.1 サウンド管理システム

**新規ファイル**: `autoload/audio_manager.gd`

```gdscript
extends Node

## AudioManager Autoload
##
## 責務:
## - サウンドエフェクトの一元管理
## - 音量調整
## - 同時再生数制限

# サウンドプール
const MAX_SOUND_INSTANCES: int = 32

var sound_pool: Array[AudioStreamPlayer] = []
var active_sounds: Array[AudioStreamPlayer] = []

# プリロードされたサウンド
var sounds: Dictionary = {
	"shoot": preload("res://assets/sounds/shoot.ogg"),
	"hit": preload("res://assets/sounds/hit.ogg"),
	"explosion": preload("res://assets/sounds/explosion.ogg"),
	"levelup": preload("res://assets/sounds/levelup.ogg"),
	"pickup": preload("res://assets/sounds/pickup.ogg"),
	"ui_click": preload("res://assets/sounds/ui_click.ogg")
}

func _ready() -> void:
	# サウンドプール初期化
	for i in range(MAX_SOUND_INSTANCES):
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.finished.connect(_on_sound_finished.bind(player))
		sound_pool.append(player)

func play_sound(sound_name: String, volume_db: float = 0.0) -> void:
	if sound_name not in sounds:
		DebugConfig.log_critical("AudioManager", "Sound not found: %s" % sound_name)
		return

	var player = _get_available_player()
	if player == null:
		return  # プール枯渇

	player.stream = sounds[sound_name]
	player.volume_db = volume_db
	player.play()
	active_sounds.append(player)

func _get_available_player() -> AudioStreamPlayer:
	if not sound_pool.is_empty():
		return sound_pool.pop_back()

	# プール枯渇時は最も古いサウンドを停止
	if not active_sounds.is_empty():
		var oldest = active_sounds[0]
		oldest.stop()
		return oldest

	return null

func _on_sound_finished(player: AudioStreamPlayer) -> void:
	active_sounds.erase(player)
	sound_pool.append(player)
```

#### 2.2 サウンド素材の準備

**方法1: フリー素材サイト**
- freesound.org
- opengameart.org
- ライセンス: CC0 または CC-BY推奨

**方法2: jsfxr（ブラウザツール）**
- https://sfxr.me/
- レトロゲーム風SE生成
- 出力: .wav（Godotで.oggに変換）

**方法3: Godot内生成（簡易）**
```gdscript
# AudioStreamGeneratorを使用した簡易SE生成
# 短いビープ音程度なら可能
```

**ディレクトリ構造**:
```
assets/
└── sounds/
    ├── shoot.ogg       # 攻撃音
    ├── hit.ogg         # ヒット音
    ├── explosion.ogg   # 爆発音
    ├── levelup.ogg     # レベルアップ音
    ├── pickup.ogg      # 経験値取得音
    └── ui_click.ogg    # UI音
```

#### 2.3 サウンド再生箇所

**攻撃音**:
```gdscript
# WeaponInstance._attack_*()内
AudioManager.play_sound("shoot", -5.0)
```

**ヒット音**:
```gdscript
# Enemy.take_damage()内
AudioManager.play_sound("hit", -10.0)
```

**爆発音**:
```gdscript
# Enemy.die()内
AudioManager.play_sound("explosion", 0.0)
```

**レベルアップ音**:
```gdscript
# Player.collect_exp()内（レベルアップ時）
AudioManager.play_sound("levelup", 5.0)
```

**経験値取得音**:
```gdscript
# Player.collect_exp()内
AudioManager.play_sound("pickup", -15.0)
```

**UI音**:
```gdscript
# UpgradePanel._on_option_selected()内
AudioManager.play_sound("ui_click", -5.0)
```

---

## 実装順序

### フェーズ1: コンテンツ（武器・敵）
1. AttackType enum拡張
2. 新しい武器Resource作成（3種類）
3. WeaponInstance拡張（攻撃ロジック）
4. 新しい敵クラス作成（2種類）
5. EnemySpawner拡張（重み付き抽選）

### フェーズ2: アップグレード
1. UpgradeType enum拡張
2. UpgradeGenerator拡張
3. UpgradeApplier拡張
4. クリティカル/範囲/弾数システム実装

### フェーズ3: パーティクル
1. 共通テクスチャ作成
2. 各エフェクトシーン作成（4種類）
3. エフェクト呼び出し実装

### フェーズ4: サウンド
1. AudioManager Autoload作成
2. サウンド素材準備（6種類）
3. サウンド再生実装

---

## データフロー図

```
Player Input
    ↓
WeaponManager
    ↓
WeaponInstance (拡張)
    ├→ _attack_penetrating() → Projectile (pierce_count=-1)
    ├→ _attack_orbital() → OrbitalNode (回転更新)
    └→ _attack_chain() → _deal_chain_damage() (再帰)

EnemySpawner (拡張)
    ├→ BasicEnemy (50%)
    ├→ StrongEnemy (20%)
    ├→ HeavyEnemy (15%)
    └→ FastEnemy (15%)

UpgradeApplier (拡張)
    ├→ critical_rate (グローバル変数)
    ├→ area_multiplier → WeaponManager.update_area_multiplier()
    └→ multishot_count → WeaponManager.update_multishot()

AudioManager (新規)
    ├→ sound_pool (32個のAudioStreamPlayer)
    └→ play_sound() → プールから取得 → 再生
```

---

## 技術的課題と解決策

### 課題1: オービタル武器の実装
**問題**: 継続的に回転する弾丸の管理
**解決策**:
- WeaponInstanceに`active_orbitals`配列を保持
- `_process()`で毎フレーム位置更新
- レベルアップ時に衛星数を増加

### 課題2: 連鎖攻撃のビジュアル
**問題**: 稲妻の線を描画
**解決策**:
- Line2Dノードを動的生成
- 0.2秒後に自動削除
- 色をグラデーション（黄→白）

### 課題3: サウンドの同時再生数制限
**問題**: 大量の敵が同時にダメージを受けるとラグ
**解決策**:
- AudioManagerでプール管理
- 最大32個まで同時再生
- 超過時は最も古いサウンドを停止

### 課題4: パーティクルのパフォーマンス
**問題**: 大量のパーティクルでFPS低下
**解決策**:
- GPUParticles2D使用（CPU負荷低減）
- amount数を控えめに設定
- one_shotで自動削除

---

## テスト計画

### 単体テスト
- [ ] 各武器が正しく動作する
- [ ] 各敵が正しくスポーンする
- [ ] 各アップグレードが正しく適用される
- [ ] パーティクルが正しく表示される
- [ ] サウンドが正しく再生される

### 統合テスト
- [ ] 新旧武器が共存して動作する
- [ ] 新旧敵が共存してスポーンする
- [ ] パーティクルとサウンドが同時に動作する

### パフォーマンステスト
- [ ] 敵100体 + パーティクル100個でFPS30以上
- [ ] サウンド32個同時再生でラグなし

---

## リスク管理

### 高リスク項目
1. **オービタル武器の実装複雑度**
   - 対策: シンプルな実装から開始、段階的に拡張

2. **サウンド素材の調達**
   - 対策: jsfxrで自作、または無音で実装（後で追加）

### 中リスク項目
1. **パーティクルのパフォーマンス影響**
   - 対策: amount数を少なめに設定、テスト実施

2. **新武器のバランス**
   - 対策: パラメータを外部から調整可能に

---

**設計書作成完了**: 2026-02-27
**次のステップ**: tasklist.md作成
