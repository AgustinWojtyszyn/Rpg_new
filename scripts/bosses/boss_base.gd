class_name BossBase
extends CharacterBody2D

signal phase_changed(phase: int)
signal boss_died

@export_range(1.0, 100000.0, 1.0) var max_health: float = 800.0
@export var phase_thresholds := PackedFloat32Array([0.70, 0.35])

@onready var health: HealthComponent = $Health

var target: Node2D
var phase_model: BossPhaseModel

func _ready() -> void:
	phase_model = BossPhaseModel.new(phase_thresholds)
	health.configure(max_health)
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)

func configure_target(new_target: Node2D) -> void:
	target = new_target

func receive_hit(amount: float) -> float:
	return health.apply_damage(amount)

func get_health_ratio() -> float:
	return health.ratio()

func _on_damaged(_amount: float, _current_health: float) -> void:
	var previous_phase := phase_model.current_phase
	var new_phase := phase_model.update(health.ratio())
	if new_phase != previous_phase:
		phase_changed.emit(new_phase)

func _on_died() -> void:
	boss_died.emit()
	queue_free()
