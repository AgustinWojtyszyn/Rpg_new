class_name BossBase
extends CharacterBody2D

signal phase_changed(phase: int)
signal boss_died

@export var display_name: String = "BOSS"
@export_range(1.0, 100000.0, 1.0) var max_health: float = 800.0
@export var phase_thresholds := PackedFloat32Array([0.70, 0.35])

@onready var health: HealthComponent = $Health

var target: Node2D
var phase_model: BossPhaseModel
var _art_sprite: Sprite2D
var _art_base_path := ""

func _ready() -> void:
	add_to_group("aim_targets")
	phase_model = BossPhaseModel.new(phase_thresholds)
	health.configure(max_health)
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	_setup_generated_art()

func _process(_delta: float) -> void:
	if not is_instance_valid(_art_sprite) or _art_base_path.is_empty():
		return
	var facing := velocity
	if facing.length_squared() < 1.0 and is_instance_valid(target):
		facing = target.global_position - global_position
	GeneratedArt.update_direction(_art_sprite, _art_base_path, facing)

func _setup_generated_art() -> void:
	match display_name:
		"T-REX":
			_art_base_path = "res://assets/generated/bosses/minibosses/miniboss_trex_final"
			_art_sprite = GeneratedArt.make_sprite(_art_base_path, 1.0, 10)
		"RIFT WARDEN":
			_art_base_path = "res://assets/generated/bosses/final/warden_final_192"
			_art_sprite = GeneratedArt.make_sprite(_art_base_path, 0.78, 10)
		_:
			return
	add_child(_art_sprite)

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
