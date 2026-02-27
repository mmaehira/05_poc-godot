extends Control

## ボスHPバーUI
## ボス出現時に表示し、撃破時に非表示

@onready var boss_name_label: Label = $BossNameLabel
@onready var health_bar: ProgressBar = $HealthBar

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

func _on_boss_defeated(_boss: Node2D) -> void:
	hide()

func _on_boss_health_changed(current: int, max: int) -> void:
	health_bar.max_value = max
	health_bar.value = current
