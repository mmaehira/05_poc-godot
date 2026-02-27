# フェーズC: 新メカニクス導入 - 設計書

**作成日**: 2026-02-27
**フェーズ**: C (New Mechanics)

---

## アーキテクチャ概要

新メカニクスは既存のシステムと疎結合を保ちつつ統合します。

```
GameManager
├── BossManager (新規)
├── PowerUpManager (新規)
├── SkillManager (新規)
├── HazardManager (新規)
├── ComboManager (新規)
└── 既存システム (EnemySpawner, PoolManager, etc.)
```

---

## 1. ボスバトルシステム

### クラス設計

#### `BossManager.gd` (AutoLoad)
```gdscript
extends Node

signal boss_spawned(boss: Node2D)
signal boss_defeated(boss: Node2D)
signal boss_health_changed(current: int, max: int)

const BOSS_SPAWN_INTERVAL: float = 180.0  # 3分

var current_boss: Node2D = null
var time_until_next_boss: float = BOSS_SPAWN_INTERVAL
var boss_scenes: Array[PackedScene] = []

func _ready() -> void:
    _load_boss_scenes()

func _load_boss_scenes() -> void:
    boss_scenes = [
        preload("res://scenes/bosses/tank_boss.tscn"),
        preload("res://scenes/bosses/sniper_boss.tscn"),
        preload("res://scenes/bosses/swarm_boss.tscn")
    ]

func _process(delta: float) -> void:
    if current_boss == null:
        time_until_next_boss -= delta
        if time_until_next_boss <= 0:
            spawn_boss()

func spawn_boss() -> void:
    var boss_scene = boss_scenes.pick_random()
    current_boss = boss_scene.instantiate()

    # 画面端からランダムに登場
    var spawn_position = _get_boss_spawn_position()
    current_boss.global_position = spawn_position

    get_tree().root.get_node("Game").add_child(current_boss)
    current_boss.health_changed.connect(_on_boss_health_changed)
    current_boss.died.connect(_on_boss_defeated)

    boss_spawned.emit(current_boss)

func _get_boss_spawn_position() -> Vector2:
    var viewport_size = get_viewport().get_visible_rect().size
    var side = randi() % 4
    match side:
        0: return Vector2(randf() * viewport_size.x, -50)      # 上
        1: return Vector2(randf() * viewport_size.x, viewport_size.y + 50)  # 下
        2: return Vector2(-50, randf() * viewport_size.y)      # 左
        _: return Vector2(viewport_size.x + 50, randf() * viewport_size.y)  # 右

func _on_boss_health_changed(current: int, max: int) -> void:
    boss_health_changed.emit(current, max)

func _on_boss_defeated() -> void:
    boss_defeated.emit(current_boss)
    current_boss = null
    time_until_next_boss = BOSS_SPAWN_INTERVAL
```

#### `Boss.gd` (Base Class)
```gdscript
extends CharacterBody2D
class_name Boss

signal health_changed(current: int, max: int)
signal died()

@export var max_health: int = 5000
@export var move_speed: float = 50.0
@export var damage: int = 20
@export var exp_value: int = 500

var current_health: int
var current_phase: int = 1  # 1 or 2
var player: Node2D = null

@onready var collision_shape = $CollisionShape2D
@onready var visual = $Visual

func _ready() -> void:
    current_health = max_health
    player = get_tree().get_first_node_in_group("player")

func take_damage(amount: int) -> void:
    current_health -= amount
    health_changed.emit(current_health, max_health)

    # フェーズ移行チェック
    if current_health <= max_health / 2 and current_phase == 1:
        _enter_phase_2()

    if current_health <= 0:
        _die()

func _enter_phase_2() -> void:
    current_phase = 2
    DebugConfig.log_info("Boss", "フェーズ2に移行!")
    # 派生クラスでオーバーライド

func _die() -> void:
    _spawn_drops()
    died.emit()
    queue_free()

func _spawn_drops() -> void:
    # 大量の経験値オーブをドロップ
    for i in range(20):
        var orb = PoolManager.get_from_pool("exp_orb")
        if orb:
            var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
            orb.global_position = global_position + offset
            orb.exp_amount = 25  # 合計500exp
```

#### `TankBoss.gd`
```gdscript
extends Boss

var attack_timer: float = 0.0
const ATTACK_INTERVAL: float = 3.0

func _ready() -> void:
    super._ready()
    max_health = 5000
    move_speed = 30.0
    damage = 30
    visual.modulate = Color.DARK_RED
    visual.custom_minimum_size = Vector2(60, 60)

func _physics_process(delta: float) -> void:
    # プレイヤーに向かって移動
    if player:
        var direction = (player.global_position - global_position).normalized()
        velocity = direction * move_speed
        move_and_slide()

    # 攻撃パターン
    attack_timer -= delta
    if attack_timer <= 0:
        if current_phase == 1:
            _attack_shockwave()
        else:
            _attack_barrage()
        attack_timer = ATTACK_INTERVAL

func _attack_shockwave() -> void:
    # 周囲360度に弾を発射
    for i in range(12):
        var angle = (TAU / 12.0) * i
        var direction = Vector2.RIGHT.rotated(angle)
        _spawn_boss_projectile(direction)

func _attack_barrage() -> void:
    # プレイヤー方向に3連射
    if player:
        var direction = (player.global_position - global_position).normalized()
        for i in range(3):
            await get_tree().create_timer(0.2).timeout
            _spawn_boss_projectile(direction)

func _spawn_boss_projectile(direction: Vector2) -> void:
    var projectile = PoolManager.get_from_pool("projectile")
    if projectile:
        projectile.global_position = global_position
        projectile.damage = damage
        projectile.direction = direction
        projectile.speed = 200.0
        projectile.modulate = Color.ORANGE_RED

func _enter_phase_2() -> void:
    super._enter_phase_2()
    move_speed = 20.0  # さらに遅く
    visual.modulate = Color.DARK_VIOLET
```

#### `SniperBoss.gd`
```gdscript
extends Boss

var attack_timer: float = 0.0
const ATTACK_INTERVAL: float = 2.0

func _ready() -> void:
    super._ready()
    max_health = 2000
    move_speed = 80.0
    damage = 50
    visual.modulate = Color.DARK_GREEN
    visual.custom_minimum_size = Vector2(40, 40)

func _physics_process(delta: float) -> void:
    # プレイヤーから距離を保つ
    if player:
        var direction = (global_position - player.global_position).normalized()
        var distance = global_position.distance_to(player.global_position)

        if distance < 300:
            velocity = direction * move_speed  # 離れる
        elif distance > 500:
            velocity = -direction * move_speed  # 近づく
        else:
            velocity = Vector2.ZERO

        move_and_slide()

    # 攻撃パターン
    attack_timer -= delta
    if attack_timer <= 0:
        if current_phase == 1:
            _attack_snipe()
        else:
            _attack_triple_snipe()
        attack_timer = ATTACK_INTERVAL

func _attack_snipe() -> void:
    # プレイヤーを狙撃
    if player:
        var direction = (player.global_position - global_position).normalized()
        _spawn_sniper_shot(direction)

func _attack_triple_snipe() -> void:
    # 3方向に同時狙撃
    if player:
        var base_direction = (player.global_position - global_position).normalized()
        for i in range(-1, 2):
            var angle_offset = deg_to_rad(15.0) * i
            var direction = base_direction.rotated(angle_offset)
            _spawn_sniper_shot(direction)

func _spawn_sniper_shot(direction: Vector2) -> void:
    var projectile = PoolManager.get_from_pool("projectile")
    if projectile:
        projectile.global_position = global_position
        projectile.damage = damage
        projectile.direction = direction
        projectile.speed = 400.0  # 高速
        projectile.modulate = Color.LIME_GREEN
```

#### `SwarmBoss.gd`
```gdscript
extends Boss

var summon_timer: float = 0.0
const SUMMON_INTERVAL: float = 5.0

func _ready() -> void:
    super._ready()
    max_health = 3000
    move_speed = 40.0
    damage = 15
    visual.modulate = Color.PURPLE
    visual.custom_minimum_size = Vector2(50, 50)

func _physics_process(delta: float) -> void:
    # ゆっくりプレイヤーに向かう
    if player:
        var direction = (player.global_position - global_position).normalized()
        velocity = direction * move_speed
        move_and_slide()

    # 召喚パターン
    summon_timer -= delta
    if summon_timer <= 0:
        if current_phase == 1:
            _summon_minions(3)
        else:
            _summon_minions(5)
        summon_timer = SUMMON_INTERVAL

func _summon_minions(count: int) -> void:
    for i in range(count):
        var enemy = PoolManager.get_from_pool("basic_enemy")
        if enemy:
            var offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
            enemy.global_position = global_position + offset
            enemy.modulate = Color.MAGENTA  # 召喚された敵の色

func _enter_phase_2() -> void:
    super._enter_phase_2()
    visual.modulate = Color.DARK_MAGENTA
```

### UI設計

#### `BossHealthBar.gd`
```gdscript
extends Control

@onready var health_bar: ProgressBar = $ProgressBar
@onready var boss_name_label: Label = $BossNameLabel

func _ready() -> void:
    BossManager.boss_spawned.connect(_on_boss_spawned)
    BossManager.boss_defeated.connect(_on_boss_defeated)
    BossManager.boss_health_changed.connect(_on_boss_health_changed)
    hide()

func _on_boss_spawned(boss: Node2D) -> void:
    boss_name_label.text = boss.name
    health_bar.max_value = boss.max_health
    health_bar.value = boss.max_health
    show()

func _on_boss_defeated(boss: Node2D) -> void:
    hide()

func _on_boss_health_changed(current: int, max: int) -> void:
    health_bar.value = current
```

---

## 2. パワーアップアイテム

### クラス設計

#### `PowerUpManager.gd` (AutoLoad)
```gdscript
extends Node

const POWERUP_SCENE = preload("res://scenes/items/powerup.tscn")
const SPAWN_INTERVAL: float = 45.0  # 45秒ごと

var spawn_timer: float = SPAWN_INTERVAL

enum PowerUpType {
    INVINCIBILITY,
    DOUBLE_DAMAGE,
    SPEED_BOOST,
    MAGNET,
    SCREEN_CLEAR
}

func _process(delta: float) -> void:
    spawn_timer -= delta
    if spawn_timer <= 0:
        spawn_powerup()
        spawn_timer = SPAWN_INTERVAL

func spawn_powerup() -> void:
    var powerup = POWERUP_SCENE.instantiate()
    powerup.powerup_type = PowerUpType.values().pick_random()
    powerup.global_position = _get_random_position()
    get_tree().root.get_node("Game").add_child(powerup)

func _get_random_position() -> Vector2:
    var viewport_size = get_viewport().get_visible_rect().size
    var player = get_tree().get_first_node_in_group("player")

    # プレイヤーから100px以上離れた位置
    var attempts = 10
    for i in range(attempts):
        var pos = Vector2(
            randf_range(50, viewport_size.x - 50),
            randf_range(50, viewport_size.y - 50)
        )
        if player and pos.distance_to(player.global_position) > 100:
            return pos

    return Vector2(viewport_size.x / 2, viewport_size.y / 2)

func apply_powerup(type: PowerUpType, player: Node2D) -> void:
    match type:
        PowerUpType.INVINCIBILITY:
            player.add_powerup_effect("invincibility", 15.0)
        PowerUpType.DOUBLE_DAMAGE:
            player.add_powerup_effect("double_damage", 15.0)
        PowerUpType.SPEED_BOOST:
            player.add_powerup_effect("speed_boost", 12.0)
        PowerUpType.MAGNET:
            player.add_powerup_effect("magnet", 15.0)
        PowerUpType.SCREEN_CLEAR:
            _clear_screen()

func _clear_screen() -> void:
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        if enemy.has_method("take_damage"):
            enemy.take_damage(999999)
```

#### `PowerUp.gd`
```gdscript
extends Area2D

@export var powerup_type: PowerUpManager.PowerUpType
@export var lifetime: float = 10.0

@onready var visual: ColorRect = $Visual
@onready var glow_particles: CPUParticles2D = $GlowParticles

var time_alive: float = 0.0

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    _setup_visual()

func _setup_visual() -> void:
    match powerup_type:
        PowerUpManager.PowerUpType.INVINCIBILITY:
            visual.color = Color.YELLOW
        PowerUpManager.PowerUpType.DOUBLE_DAMAGE:
            visual.color = Color.RED
        PowerUpManager.PowerUpType.SPEED_BOOST:
            visual.color = Color.CYAN
        PowerUpManager.PowerUpType.MAGNET:
            visual.color = Color.GREEN
        PowerUpManager.PowerUpType.SCREEN_CLEAR:
            visual.color = Color.GOLD

    glow_particles.color = visual.color

func _process(delta: float) -> void:
    time_alive += delta
    if time_alive >= lifetime:
        queue_free()

    # 点滅エフェクト（消える直前）
    if time_alive >= lifetime - 2.0:
        visual.modulate.a = 0.5 + 0.5 * sin(time_alive * 10.0)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        PowerUpManager.apply_powerup(powerup_type, body)
        AudioManager.play_sfx("pickup", -10.0)
        queue_free()
```

#### `Player.gd`への拡張
```gdscript
# 既存のPlayer.gdに追加
var active_powerups: Dictionary = {}  # {"invincibility": 5.3, "double_damage": 10.2}

func _process(delta: float) -> void:
    # ... 既存処理 ...

    # パワーアップ効果の時間管理
    for powerup_name in active_powerups.keys():
        active_powerups[powerup_name] -= delta
        if active_powerups[powerup_name] <= 0:
            active_powerups.erase(powerup_name)
            DebugConfig.log_debug("Player", "パワーアップ終了: " + powerup_name)

func add_powerup_effect(powerup_name: String, duration: float) -> void:
    active_powerups[powerup_name] = duration
    DebugConfig.log_info("Player", "パワーアップ取得: " + powerup_name)

func has_powerup(powerup_name: String) -> bool:
    return active_powerups.has(powerup_name)

func take_damage(amount: int) -> void:
    if has_powerup("invincibility"):
        DebugConfig.log_debug("Player", "無敵状態でダメージ無効化")
        return

    # ... 既存のダメージ処理 ...
```

---

## 3. プレイヤー特殊能力

### クラス設計

#### `SkillManager.gd` (Player子ノード)
```gdscript
extends Node

signal skill_used(skill_name: String)
signal cooldown_started(skill_name: String, duration: float)
signal cooldown_updated(skill_name: String, remaining: float)

enum SkillType {
    DASH,
    NOVA_BLAST,
    SHIELD,
    TIME_SLOW
}

var selected_skill: SkillType
var cooldown_remaining: float = 0.0
var skill_cooldowns: Dictionary = {
    SkillType.DASH: 5.0,
    SkillType.NOVA_BLAST: 10.0,
    SkillType.SHIELD: 15.0,
    SkillType.TIME_SLOW: 20.0
}

@onready var player: CharacterBody2D = get_parent()

func _ready() -> void:
    # デフォルトスキル（後で選択画面から設定）
    selected_skill = SkillType.DASH

func _process(delta: float) -> void:
    if cooldown_remaining > 0:
        cooldown_remaining -= delta
        cooldown_updated.emit(SkillType.keys()[selected_skill], cooldown_remaining)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("use_skill") and cooldown_remaining <= 0:
        use_skill()

func use_skill() -> void:
    match selected_skill:
        SkillType.DASH:
            _skill_dash()
        SkillType.NOVA_BLAST:
            _skill_nova_blast()
        SkillType.SHIELD:
            _skill_shield()
        SkillType.TIME_SLOW:
            _skill_time_slow()

    cooldown_remaining = skill_cooldowns[selected_skill]
    skill_used.emit(SkillType.keys()[selected_skill])
    cooldown_started.emit(SkillType.keys()[selected_skill], cooldown_remaining)
    AudioManager.play_sfx("skill_use", -8.0)

func _skill_dash() -> void:
    var dash_direction = player.velocity.normalized()
    if dash_direction == Vector2.ZERO:
        dash_direction = Vector2.RIGHT

    player.add_powerup_effect("invincibility", 0.3)

    var dash_distance = 150.0
    var dash_duration = 0.2
    var tween = create_tween()
    tween.tween_property(player, "global_position",
        player.global_position + dash_direction * dash_distance, dash_duration)

func _skill_nova_blast() -> void:
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        var distance = player.global_position.distance_to(enemy.global_position)
        if distance <= 200 and enemy.has_method("take_damage"):
            enemy.take_damage(100)

    # 爆発エフェクト
    var explosion = PoolManager.get_from_pool("explosion")
    if explosion:
        explosion.global_position = player.global_position
        explosion.scale = Vector2(3.0, 3.0)

func _skill_shield() -> void:
    player.add_powerup_effect("invincibility", 3.0)
    # シールド視覚エフェクト（Playerに追加）
    player.show_shield_effect(3.0)

func _skill_time_slow() -> void:
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        if enemy.has("move_speed"):
            var original_speed = enemy.move_speed
            enemy.move_speed *= 0.5

            # 5秒後に元に戻す
            await get_tree().create_timer(5.0).timeout
            enemy.move_speed = original_speed
```

---

## 4. 環境ハザード

### クラス設計

#### `HazardManager.gd` (AutoLoad)
```gdscript
extends Node

const HAZARD_SCENE = preload("res://scenes/hazards/hazard.tscn")
const SPAWN_INTERVAL: float = 20.0

var spawn_timer: float = SPAWN_INTERVAL

enum HazardType {
    LAVA_POOL,
    POISON_CLOUD,
    LIGHTNING_STRIKE,
    ICE_PATCH
}

func _process(delta: float) -> void:
    spawn_timer -= delta
    if spawn_timer <= 0:
        spawn_hazard()
        spawn_timer = SPAWN_INTERVAL

func spawn_hazard() -> void:
    var hazard = HAZARD_SCENE.instantiate()
    hazard.hazard_type = HazardType.values().pick_random()
    hazard.global_position = _get_safe_spawn_position()
    get_tree().root.get_node("Game").add_child(hazard)

func _get_safe_spawn_position() -> Vector2:
    var viewport_size = get_viewport().get_visible_rect().size
    var player = get_tree().get_first_node_in_group("player")

    # プレイヤーから100px以上離れた位置
    for i in range(10):
        var pos = Vector2(
            randf_range(100, viewport_size.x - 100),
            randf_range(100, viewport_size.y - 100)
        )
        if player and pos.distance_to(player.global_position) > 100:
            return pos

    return Vector2(viewport_size.x / 2, viewport_size.y / 2)
```

#### `Hazard.gd`
```gdscript
extends Area2D

@export var hazard_type: HazardManager.HazardType

var warning_duration: float = 1.0
var active_duration: float = 0.0
var is_active: bool = false

@onready var warning_visual: ColorRect = $WarningVisual
@onready var active_visual: ColorRect = $ActiveVisual
@onready var particles: CPUParticles2D = $Particles

func _ready() -> void:
    _setup_hazard()
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

    # 警告フェーズ
    warning_visual.show()
    active_visual.hide()
    await get_tree().create_timer(warning_duration).timeout

    # アクティブフェーズ
    _activate()

func _setup_hazard() -> void:
    match hazard_type:
        HazardManager.HazardType.LAVA_POOL:
            active_duration = 8.0
            warning_visual.color = Color(1.0, 0.3, 0.3, 0.5)
            active_visual.color = Color.ORANGE_RED
            particles.color = Color.ORANGE
        HazardManager.HazardType.POISON_CLOUD:
            active_duration = 12.0
            warning_visual.color = Color(0.3, 1.0, 0.3, 0.5)
            active_visual.color = Color.GREEN_YELLOW
            particles.color = Color.CHARTREUSE
        HazardManager.HazardType.LIGHTNING_STRIKE:
            active_duration = 0.1  # 一瞬
            warning_visual.color = Color(1.0, 1.0, 0.3, 0.5)
            active_visual.color = Color.YELLOW
            particles.color = Color.YELLOW
        HazardManager.HazardType.ICE_PATCH:
            active_duration = 10.0
            warning_visual.color = Color(0.3, 0.8, 1.0, 0.5)
            active_visual.color = Color.LIGHT_CYAN
            particles.color = Color.CYAN

func _activate() -> void:
    is_active = true
    warning_visual.hide()
    active_visual.show()
    particles.emitting = true
    AudioManager.play_sfx("hazard_activate", -12.0)

    # 雷は即座にダメージ
    if hazard_type == HazardManager.HazardType.LIGHTNING_STRIKE:
        _deal_instant_damage()

    await get_tree().create_timer(active_duration).timeout
    queue_free()

func _deal_instant_damage() -> void:
    var bodies = get_overlapping_bodies()
    for body in bodies:
        if body.has_method("take_damage"):
            body.take_damage(100)

var bodies_in_hazard: Array = []

func _on_body_entered(body: Node2D) -> void:
    if is_active and not bodies_in_hazard.has(body):
        bodies_in_hazard.append(body)

func _on_body_exited(body: Node2D) -> void:
    bodies_in_hazard.erase(body)

func _process(delta: float) -> void:
    if not is_active:
        return

    # 継続ダメージ（溶岩と毒）
    if hazard_type == HazardManager.HazardType.LAVA_POOL:
        for body in bodies_in_hazard:
            if body.has_method("take_damage"):
                body.take_damage(int(10 * delta))  # 毎秒10ダメージ

    elif hazard_type == HazardManager.HazardType.POISON_CLOUD:
        for body in bodies_in_hazard:
            if body.has_method("take_damage"):
                body.take_damage(int(5 * delta))  # 毎秒5ダメージ

    # 氷床は移動速度減少（Playerに実装）
    elif hazard_type == HazardManager.HazardType.ICE_PATCH:
        for body in bodies_in_hazard:
            if body.is_in_group("player"):
                body.set_meta("on_ice", true)
```

---

## 5. コンボシステム

### クラス設計

#### `ComboManager.gd` (AutoLoad)
```gdscript
extends Node

signal combo_increased(combo: int)
signal combo_broken(final_combo: int)
signal combo_multiplier_changed(multiplier: float)

var current_combo: int = 0
var combo_timer: float = 0.0
const COMBO_TIMEOUT: float = 3.0

func _process(delta: float) -> void:
    if current_combo > 0:
        combo_timer -= delta
        if combo_timer <= 0:
            break_combo()

func add_combo() -> void:
    current_combo += 1
    combo_timer = COMBO_TIMEOUT
    combo_increased.emit(current_combo)

    var multiplier = get_exp_multiplier()
    combo_multiplier_changed.emit(multiplier)

func break_combo() -> void:
    var final = current_combo
    current_combo = 0
    combo_timer = 0.0
    combo_broken.emit(final)

func get_exp_multiplier() -> float:
    if current_combo >= 100:
        return 2.0
    elif current_combo >= 50:
        return 1.5
    elif current_combo >= 20:
        return 1.2
    elif current_combo >= 10:
        return 1.1
    else:
        return 1.0

func get_combo() -> int:
    return current_combo

func get_time_remaining() -> float:
    return combo_timer
```

#### `Enemy.gd`への拡張
```gdscript
# 既存のEnemy.gdの_die()に追加
func _die() -> void:
    ComboManager.add_combo()  # コンボ加算

    # 経験値にコンボボーナスを適用
    var base_exp = exp_value
    var multiplier = ComboManager.get_exp_multiplier()
    var final_exp = int(base_exp * multiplier)

    _spawn_exp_orbs(final_exp)
    # ... 既存処理 ...
```

---

## データ構造

### ボスデータ
```gdscript
# resources/bosses/boss_data.gd
extends Resource
class_name BossData

@export var boss_name: String = "Unknown Boss"
@export var max_health: int = 5000
@export var move_speed: float = 50.0
@export var damage: int = 20
@export var exp_value: int = 500
@export var phase_2_hp_threshold: float = 0.5  # HP 50%でフェーズ2
```

---

## UI/UX設計

### HUDへの追加要素

```
┌─────────────────────────────────────────────┐
│ [Boss HP Bar] ████████████░░░░░ 60%        │  ← ボスHPバー
├─────────────────────────────────────────────┤
│  Combo: 45x  ████░░░  (2.5s)               │  ← コンボ表示+タイマー
│                                             │
│                                 ┌─────────┐ │
│                                 │ [無] 5s │ │  ← パワーアップタイマー
│                                 │ [攻] 3s │ │
│                                 └─────────┘ │
│                                             │
│                                             │
│  [スキルアイコン] ████████░░░ 70%          │  ← スキルクールダウン
└─────────────────────────────────────────────┘
```

---

## ファイル構成

```
/workspaces/05_poc-godot/
├── autoload/
│   ├── boss_manager.gd (新規)
│   ├── powerup_manager.gd (新規)
│   ├── hazard_manager.gd (新規)
│   └── combo_manager.gd (新規)
├── scripts/
│   ├── bosses/
│   │   ├── boss.gd (新規)
│   │   ├── tank_boss.gd (新規)
│   │   ├── sniper_boss.gd (新規)
│   │   └── swarm_boss.gd (新規)
│   ├── player/
│   │   └── skill_manager.gd (新規)
│   ├── items/
│   │   └── powerup.gd (新規)
│   └── hazards/
│       └── hazard.gd (新規)
├── scenes/
│   ├── bosses/
│   │   ├── tank_boss.tscn (新規)
│   │   ├── sniper_boss.tscn (新規)
│   │   └── swarm_boss.tscn (新規)
│   ├── items/
│   │   └── powerup.tscn (新規)
│   ├── hazards/
│   │   └── hazard.tscn (新規)
│   └── ui/
│       ├── boss_health_bar.tscn (新規)
│       ├── combo_display.tscn (新規)
│       ├── powerup_timer_display.tscn (新規)
│       └── skill_cooldown_display.tscn (新規)
└── resources/
    └── bosses/
        ├── tank_boss_data.tres (新規)
        ├── sniper_boss_data.tres (新規)
        └── swarm_boss_data.tres (新規)
```

---

## 実装順序

1. **コンボシステム** - 最もシンプル、既存システムへの影響が小さい
2. **パワーアップアイテム** - アイテム生成とPlayer拡張
3. **環境ハザード** - Area2Dベースで実装しやすい
4. **プレイヤー特殊能力** - Input処理とPlayerの拡張
5. **ボスバトルシステム** - 最も複雑、他の要素を活用

---

## テスト計画

- [ ] コンボが正しく加算され、タイムアウトで途切れる
- [ ] パワーアップが正しく適用され、時間で消える
- [ ] ハザードの警告→発動が正しく動作する
- [ ] スキルのクールダウンが正しく機能する
- [ ] ボスが正しく出現し、攻撃パターンが動作する
- [ ] ボスのフェーズ移行が正しく発生する
- [ ] 全ての新メカニクスが同時に動作してもFPS 60を維持

---

## 次のステップ

この設計が承認されたら、`tasklist.md`で実装タスクを作成します。
