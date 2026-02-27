# design.md
初期実装の設計内容

---

## 実装順序

### フェーズ1: 基盤システム（Autoload）
1. GameManager
2. LevelSystem
3. PoolManager

### フェーズ2: プレイヤーシステム
4. Player（移動のみ）
5. WeaponManager
6. Weapon Resource
7. WeaponInstance
8. Projectile

### フェーズ3: 敵システム
9. AIController Resource
10. AIChasePlayer
11. Enemy基底クラス
12. BasicEnemy
13. StrongEnemy
14. EnemySpawner

### フェーズ4: アイテムシステム
15. ExpOrb

### フェーズ5: レベルアップシステム
16. UpgradeGenerator
17. UpgradeApplier
18. UpgradePanel（UI）

### フェーズ6: UIシステム
19. HUD
20. GameOverScreen
21. TitleScreen

### フェーズ7: シーン統合
22. game.tscn統合
23. main.tscn統合

---

## 詳細設計

### 1. GameManager（autoload/game_manager.gd）

**責務**: ゲーム状態管理、ポーズ制御

**クラス構造**:
```gdscript
extends Node

enum GameState {
    TITLE,
    PLAYING,
    PAUSED,
    UPGRADE,
    GAME_OVER
}

signal state_changed(new_state: GameState)
signal game_started()
signal game_over()

var current_state: GameState = GameState.TITLE
var game_stats: GameStats = null

func _ready() -> void
func change_state(new_state: GameState) -> void
func start_game() -> void
func end_game() -> void
func pause_game() -> void
func resume_game() -> void
```

**重要ポイント**:
- 純粋Autoload（シーンに配置しない）
- `get_tree().paused`を制御する唯一の権限者
- game_statsはGameStats Resource（Dictionaryではない）

---

### 2. LevelSystem（autoload/level_system.gd）

**責務**: 経験値・レベル管理

**クラス構造**:
```gdscript
extends Node

signal level_up(new_level: int)
signal exp_changed(current_exp: int, next_level_exp: int)

const BASE_EXP: int = 10
const EXP_GROWTH_RATE: float = 1.18

var current_level: int = 1
var experience: int = 0
var next_level_exp: int = BASE_EXP

func _ready() -> void
func add_exp(amount: int) -> bool
func reset() -> void
func _calculate_next_level_exp(level: int) -> int
func _check_level_up() -> bool
```

**重要ポイント**:
- 経験値の唯一の管理者（Playerには持たせない）
- レベルアップ判定は`add_exp()`内で自動実行
- `reset()`でGameManager.start_game()から呼ばれる

---

### 3. PoolManager（autoload/pool_manager.gd）

**責務**: オブジェクトプール管理

**クラス構造**:
```gdscript
extends Node

const MAX_ENEMY_POOL_SIZE: int = 200
const MAX_PROJECTILE_POOL_SIZE: int = 500
const MAX_EXP_ORB_POOL_SIZE: int = 200

var enemy_pools: Dictionary = {}  # {scene_path: Array[Node]}
var active_enemies: Dictionary = {}  # {scene_path: Array[Node]}
var projectile_pool: Array[Node] = []
var active_projectiles: Array[Node] = []
var exp_orb_pool: Array[Node] = []
var active_exp_orbs: Array[Node] = []
var world_node: Node = null  # GameSceneから設定

func set_world_node(node: Node) -> void
func spawn_enemy(scene_path: String, position: Vector2) -> Node
func return_enemy(enemy: Node) -> void
func spawn_projectile(position: Vector2, direction: Vector2, damage: int) -> Node
func return_projectile(projectile: Node) -> void
func spawn_exp_orb(position: Vector2, exp_value: int) -> Node
func return_exp_orb(orb: Node) -> void
func clear_all_active() -> void
func _ensure_enemy_pool(scene_path: String) -> void
func _reparent_to_world(node: Node) -> void
```

**重要ポイント**:
- シーンパス別Dictionary（enemy_pools）で型混在防止
- world_nodeへのreparent必須（Autoload直下に配置しない）
- LRU方式でプール上限管理

---

### 4. Player（scripts/player/player.gd + scenes/player/player.tscn）

**責務**: 移動入力、HP管理、経験値オーブ回収

**クラス構造**:
```gdscript
class_name Player extends CharacterBody2D

signal hp_changed(new_hp: int, max_hp: int)
signal died()

const BASE_SPEED: float = 200.0

@export var max_hp: int = 100
@export var speed: float = BASE_SPEED

var current_hp: int = max_hp

@onready var weapon_manager: WeaponManager = $WeaponManager
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var exp_attract_area: Area2D = $ExpAttractArea

func _ready() -> void
func _process(delta: float) -> void
func _handle_input() -> Vector2
func _handle_exp_collection() -> void
func take_damage(amount: int) -> void
func heal(amount: int) -> void
func _on_exp_attract_area_entered(area: Area2D) -> void
```

**シーン構造**:
```
Player (CharacterBody2D)
├─ Sprite2D
├─ CollisionShape2D
├─ WeaponManager (Node)
└─ ExpAttractArea (Area2D)
   └─ CollisionShape2D
```

**重要ポイント**:
- 経験値は保持しない（LevelSystem.add_exp()に委譲）
- ExpAttractAreaで経験値オーブを吸引

---

### 5. WeaponManager（scripts/player/weapon_manager.gd）

**責務**: 武器インスタンス管理

**クラス構造**:
```gdscript
class_name WeaponManager extends Node

const MAX_WEAPONS: int = 6

var weapons: Array[WeaponInstance] = []

func add_weapon(weapon_data: Weapon) -> bool
func level_up_weapon(weapon_name: String) -> bool
func has_weapon(weapon_name: String) -> bool
func get_weapon_level(weapon_name: String) -> int
func _find_weapon(weapon_name: String) -> WeaponInstance
```

**重要ポイント**:
- 最大6個の武器スロット
- 同名武器は追加不可（レベルアップのみ）

---

### 6. Weapon（resources/weapon.gd）

**責務**: 武器データ定義

**クラス構造**:
```gdscript
class_name Weapon extends Resource

enum AttackType {
    STRAIGHT_SHOT,
    AREA_BLAST,
    HOMING_MISSILE
}

@export var weapon_name: String = ""
@export var description: String = ""
@export var base_damage: int = 10
@export var attack_interval: float = 1.0
@export var attack_type: AttackType = AttackType.STRAIGHT_SHOT
@export var projectile_count: int = 1
@export var projectile_speed: float = 300.0
```

**3種類の武器データ（.tres）**:
1. **straight_shot.tres**:
   - weapon_name: "直線ショット"
   - base_damage: 10
   - attack_interval: 0.5
   - attack_type: STRAIGHT_SHOT
   - projectile_count: 1

2. **area_blast.tres**:
   - weapon_name: "範囲爆発"
   - base_damage: 15
   - attack_interval: 2.0
   - attack_type: AREA_BLAST
   - projectile_count: 8

3. **homing_missile.tres**:
   - weapon_name: "ホーミングミサイル"
   - base_damage: 20
   - attack_interval: 1.5
   - attack_type: HOMING_MISSILE
   - projectile_count: 1

---

### 7. WeaponInstance（scripts/weapons/weapon_instance.gd）

**責務**: 武器の実体、攻撃処理

**クラス構造**:
```gdscript
class_name WeaponInstance extends Node

var weapon_data: Weapon = null
var current_level: int = 1
var owner_player: Node = null
var _attack_timer: float = 0.0

func initialize(weapon: Weapon, level: int, player: Node) -> void
func _ready() -> void
func _process(delta: float) -> void
func level_up() -> void
func _can_attack() -> bool
func _attack() -> void
func _attack_straight_shot() -> void
func _attack_area_blast() -> void
func _attack_homing_missile() -> void
func _get_nearest_enemy() -> Node
```

**重要ポイント**:
- owner_playerを直接参照（get_parent()禁止）
- 武器方向は`owner_player.velocity.normalized()`
- 停止中はVector2.RIGHTをデフォルト

---

### 8. Projectile（scripts/weapons/projectile.gd + scenes/weapons/projectile.tscn）

**責務**: 弾丸の移動、衝突処理

**クラス構造**:
```gdscript
class_name Projectile extends Area2D

var damage: int = 0
var speed: float = 300.0
var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 5.0
var is_homing: bool = false
var _elapsed_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func initialize(pos: Vector2, dir: Vector2, dmg: int, spd: float, homing: bool = false) -> void
func _ready() -> void
func _process(delta: float) -> void
func _update_homing_direction() -> void
func _on_area_entered(area: Area2D) -> void
func _on_body_entered(body: Node2D) -> void
func _return_to_pool() -> void
```

**シーン構造**:
```
Projectile (Area2D)
├─ Sprite2D
└─ CollisionShape2D
```

---

### 9. AIController（resources/ai_controller.gd）

**責務**: AI行動パターン基底クラス

**クラス構造**:
```gdscript
class_name AIController extends Resource

func calculate_direction(enemy: Node, player: Node, delta: float) -> Vector2:
    push_error("AIController.calculate_direction() must be overridden")
    return Vector2.ZERO
```

---

### 10. AIChasePlayer（resources/ai_chase_player.gd）

**責務**: プレイヤー追跡AI

**クラス構造**:
```gdscript
class_name AIChasePlayer extends AIController

func calculate_direction(enemy: Node, player: Node, delta: float) -> Vector2:
    if player == null:
        return Vector2.ZERO
    return (player.global_position - enemy.global_position).normalized()
```

---

### 11. Enemy（scripts/enemies/enemy.gd）

**責務**: 敵基底クラス

**クラス構造**:
```gdscript
class_name Enemy extends CharacterBody2D

signal died(enemy: Enemy)

@export var max_hp: int = 30
@export var speed: float = 100.0
@export var contact_damage: int = 10
@export var exp_value: int = 5
@export var ai_controller: AIController = null

var current_hp: int = max_hp
var player: Node = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func initialize(pos: Vector2, target_player: Node) -> void
func _ready() -> void
func _process(delta: float) -> void
func take_damage(amount: int) -> void
func _die() -> void
func _on_body_entered(body: Node2D) -> void
```

**シーン構造**:
```
Enemy (CharacterBody2D)
├─ Sprite2D
└─ CollisionShape2D
```

---

### 12. BasicEnemy（scripts/enemies/basic_enemy.gd + scenes/enemies/basic_enemy.tscn）

**パラメータ**:
- max_hp: 30
- speed: 100.0
- contact_damage: 10
- exp_value: 5

---

### 13. StrongEnemy（scripts/enemies/strong_enemy.gd + scenes/enemies/strong_enemy.tscn）

**パラメータ**:
- max_hp: 80
- speed: 80.0
- contact_damage: 20
- exp_value: 15

---

### 14. EnemySpawner（scripts/systems/enemy_spawner.gd）

**責務**: 敵のスポーン制御

**クラス構造**:
```gdscript
class_name EnemySpawner extends Node

const BASIC_ENEMY_SCENE: String = "res://scenes/enemies/basic_enemy.tscn"
const STRONG_ENEMY_SCENE: String = "res://scenes/enemies/strong_enemy.tscn"

@export var base_spawn_interval: float = 2.0
@export var difficulty_curve: Curve = null
@export var spawn_radius: float = 600.0

var player: Node = null
var game_start_time: int = 0
var _spawn_timer: float = 0.0

func initialize(target_player: Node) -> void
func _ready() -> void
func _process(delta: float) -> void
func _spawn_enemy() -> void
func _get_spawn_position() -> Vector2
func _choose_enemy_scene() -> String
func _get_game_progress() -> float
```

**重要ポイント**:
- 難易度曲線でスポーン間隔を動的調整
- 70/30の確率でBasic/Strong選択
- 画面外にスポーン

---

### 15. ExpOrb（scripts/items/exp_orb.gd + scenes/items/exp_orb.tscn）

**責務**: 経験値オーブ

**クラス構造**:
```gdscript
class_name ExpOrb extends Area2D

var exp_value: int = 5
var attract_speed: float = 400.0
var is_attracted: bool = false
var target_player: Node = null

@onready var sprite: Sprite2D = $Sprite2D

func initialize(pos: Vector2, exp: int) -> void
func _ready() -> void
func _process(delta: float) -> void
func _move_to_player(delta: float) -> void
func _on_area_entered(area: Area2D) -> void
```

**シーン構造**:
```
ExpOrb (Area2D)
├─ Sprite2D
└─ CollisionShape2D
```

---

### 16. UpgradeGenerator（scripts/systems/upgrade_generator.gd）

**責務**: レベルアップ時の3択生成

**クラス構造**:
```gdscript
class_name UpgradeGenerator extends Node

enum UpgradeType {
    NEW_WEAPON,
    WEAPON_LEVEL_UP,
    MAX_HP,
    SPEED
}

enum Rarity {
    COMMON,  # 70%
    RARE     # 30%
}

const RARITY_WEIGHTS: Dictionary = {
    Rarity.COMMON: 70,
    Rarity.RARE: 30
}

func generate_choices(player: Node, weapon_manager: WeaponManager) -> Array[Dictionary]
func _generate_single_choice(player: Node, weapon_manager: WeaponManager, exclude_types: Array[UpgradeType]) -> Dictionary
func _determine_rarity() -> Rarity
func _get_available_weapon() -> Weapon
func _get_upgradeable_weapon(weapon_manager: WeaponManager) -> String
```

**選択肢の構造**:
```gdscript
{
    "type": UpgradeType,
    "rarity": Rarity,
    "display_name": String,
    "description": String,
    "value": Variant  # 武器データ or 数値
}
```

---

### 17. UpgradeApplier（scripts/systems/upgrade_applier.gd）

**責務**: アップグレード効果適用

**クラス構造**:
```gdscript
class_name UpgradeApplier extends Node

func apply_upgrade(choice: Dictionary, player: Node, weapon_manager: WeaponManager) -> void
func _apply_new_weapon(weapon_data: Weapon, weapon_manager: WeaponManager) -> void
func _apply_weapon_level_up(weapon_name: String, weapon_manager: WeaponManager) -> void
func _apply_max_hp(amount: int, player: Node) -> void
func _apply_speed(amount: float, player: Node) -> void
```

---

### 18. UpgradePanel（scripts/ui/upgrade_panel.gd + scenes/ui/upgrade_panel.tscn）

**責務**: レベルアップUIの表示・選択受付

**クラス構造**:
```gdscript
class_name UpgradePanel extends Control

signal choice_selected(choice: Dictionary)

@onready var choice_button_1: Button = $VBoxContainer/ChoiceButton1
@onready var choice_button_2: Button = $VBoxContainer/ChoiceButton2
@onready var choice_button_3: Button = $VBoxContainer/ChoiceButton3

var current_choices: Array[Dictionary] = []

func _ready() -> void
func show_choices(choices: Array[Dictionary]) -> void
func _on_choice_button_1_pressed() -> void
func _on_choice_button_2_pressed() -> void
func _on_choice_button_3_pressed() -> void
func _update_button(button: Button, choice: Dictionary) -> void
```

**シーン構造**:
```
UpgradePanel (Control) [process_mode = ALWAYS]
└─ VBoxContainer
   ├─ ChoiceButton1 (Button)
   ├─ ChoiceButton2 (Button)
   └─ ChoiceButton3 (Button)
```

---

### 19. HUD（scripts/ui/hud.gd + scenes/ui/hud.tscn）

**責務**: ゲーム情報表示

**クラス構造**:
```gdscript
class_name HUD extends CanvasLayer

@onready var hp_label: Label = $MarginContainer/VBoxContainer/HPLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var exp_bar: ProgressBar = $MarginContainer/VBoxContainer/ExpBar
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel

var game_start_time: int = 0

func _ready() -> void
func _process(delta: float) -> void
func _update_hp(current_hp: int, max_hp: int) -> void
func _update_level(level: int) -> void
func _update_exp(current_exp: int, next_level_exp: int) -> void
func _update_time() -> void
func _on_player_hp_changed(new_hp: int, max_hp: int) -> void
func _on_level_system_exp_changed(current_exp: int, next_level_exp: int) -> void
```

**シーン構造**:
```
HUD (CanvasLayer)
└─ MarginContainer
   └─ VBoxContainer
      ├─ HPLabel
      ├─ LevelLabel
      ├─ ExpBar (ProgressBar)
      └─ TimeLabel
```

---

### 20. GameOverScreen（scripts/ui/game_over_screen.gd + scenes/ui/game_over_screen.tscn）

**責務**: ゲームオーバー表示

**クラス構造**:
```gdscript
class_name GameOverScreen extends Control

@onready var stats_label: Label = $CenterContainer/VBoxContainer/StatsLabel
@onready var retry_button: Button = $CenterContainer/VBoxContainer/RetryButton
@onready var title_button: Button = $CenterContainer/VBoxContainer/TitleButton

func _ready() -> void
func show_game_over(game_stats: GameStats) -> void
func _on_retry_button_pressed() -> void
func _on_title_button_pressed() -> void
```

**シーン構造**:
```
GameOverScreen (Control) [process_mode = ALWAYS]
└─ CenterContainer
   └─ VBoxContainer
      ├─ TitleLabel
      ├─ StatsLabel
      ├─ RetryButton
      └─ TitleButton
```

---

### 21. TitleScreen（scripts/ui/title_screen.gd + scenes/title.tscn）

**責務**: タイトル画面

**クラス構造**:
```gdscript
extends Control

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void
func _on_start_button_pressed() -> void
func _on_quit_button_pressed() -> void
```

---

### 22. game.tscn（scenes/game.tscn）

**シーン構造**:
```
GameScene (Node2D)
├─ WorldNode (Node2D)  # PoolManagerがここに敵/弾丸/オーブをreparent
├─ Player (CharacterBody2D)
├─ EnemySpawner (Node)
├─ UpgradeGenerator (Node)
├─ UpgradeApplier (Node)
├─ HUD (CanvasLayer)
├─ UpgradePanel (Control)
└─ GameOverScreen (Control)
```

**スクリプト（scenes/game.tscn直接）**:
```gdscript
extends Node2D

@onready var world_node: Node2D = $WorldNode
@onready var player: Player = $Player
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var upgrade_generator: UpgradeGenerator = $UpgradeGenerator
@onready var upgrade_applier: UpgradeApplier = $UpgradeApplier
@onready var upgrade_panel: UpgradePanel = $UpgradePanel
@onready var game_over_screen: GameOverScreen = $GameOverScreen

func _ready() -> void
func _on_level_system_level_up(new_level: int) -> void
func _on_upgrade_panel_choice_selected(choice: Dictionary) -> void
func _on_player_died() -> void
```

---

### 23. main.tscn（scenes/main.tscn）

**シーン構造**:
```
Main (Node)
```

**スクリプト**:
```gdscript
extends Node

func _ready() -> void
    GameManager.game_started.connect(_on_game_started)
    GameManager.change_state(GameManager.GameState.TITLE)
    get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_game_started() -> void
    get_tree().change_scene_to_file("res://scenes/game.tscn")
```

---

## GameStats Resource（resources/game_stats.gd）

**クラス構造**:
```gdscript
class_name GameStats extends Resource

var start_time: int = 0
var kill_count: int = 0
var damage_dealt: int = 0
var damage_taken: int = 0

func reset() -> void:
    start_time = Time.get_ticks_msec()
    kill_count = 0
    damage_dealt = 0
    damage_taken = 0

func get_elapsed_time() -> float:
    return (Time.get_ticks_msec() - start_time) / 1000.0
```

---

## 仮アセット

### スプライト
- Player: 32x32白い四角
- BasicEnemy: 24x24赤い丸
- StrongEnemy: 32x32赤い四角
- Projectile: 8x8黄色い丸
- ExpOrb: 12x12緑の星

### フォント
- システムデフォルトフォント

---

## project.godot設定

### [application]
```ini
config/name="POC Godot Roguelite"
run/main_scene="res://scenes/main.tscn"
config/features=PackedStringArray("4.3", "Forward Plus")
```

### [autoload]
```ini
GameManager="*res://autoload/game_manager.gd"
LevelSystem="*res://autoload/level_system.gd"
PoolManager="*res://autoload/pool_manager.gd"
```

### [input]
```ini
ui_left={
"deadzone": 0.5,
"events": [InputEventKey(keycode=KEY_A), InputEventKey(keycode=KEY_LEFT)]
}
ui_right={
"deadzone": 0.5,
"events": [InputEventKey(keycode=KEY_D), InputEventKey(keycode=KEY_RIGHT)]
}
ui_up={
"deadzone": 0.5,
"events": [InputEventKey(keycode=KEY_W), InputEventKey(keycode=KEY_UP)]
}
ui_down={
"deadzone": 0.5,
"events": [InputEventKey(keycode=KEY_S), InputEventKey(keycode=KEY_DOWN)]
}
```

---

## テスト計画

### 手動テスト項目

#### 基本動作
1. プレイヤー移動（WASD/矢印）
2. 武器自動攻撃
3. 敵スポーン
4. 敵の追跡AI
5. 弾丸と敵の衝突
6. 敵撃破で経験値オーブドロップ
7. 経験値オーブ回収
8. レベルアップで3択表示
9. アップグレード選択で効果適用
10. HP減少で死亡
11. ゲームオーバー画面表示
12. リトライ機能

#### パフォーマンス
1. 敵100体同時スポーン
2. 弾丸300発同時表示
3. 15分間プレイ

#### エッジケース
1. 武器6個所持時の新武器追加試行
2. プール上限到達時の動作
3. ポーズ中の入力遮断
4. レベルアップ中の時間停止

---

**設計完了**: 全23コンポーネントの詳細設計を完了
