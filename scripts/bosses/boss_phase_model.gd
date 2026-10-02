class_name BossPhaseModel
extends RefCounted

var thresholds: PackedFloat32Array
var current_phase: int = 0

func _init(values: PackedFloat32Array = PackedFloat32Array([0.70, 0.35])) -> void:
	thresholds = values.duplicate()

func update(health_ratio: float) -> int:
	var clamped_ratio := clampf(health_ratio, 0.0, 1.0)
	while current_phase < thresholds.size() and clamped_ratio <= thresholds[current_phase]:
		current_phase += 1
	return current_phase
