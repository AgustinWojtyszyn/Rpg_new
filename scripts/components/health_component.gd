class_name HealthComponent
extends Node

signal damaged(amount: float, current_health: float)
signal healed(amount: float, current_health: float)
signal died

@export_range(1.0, 100000.0, 1.0) var max_health: float = 100.0
var current_health: float = 100.0

func _ready() -> void:
	current_health = max_health

func configure(new_max_health: float, refill: bool = true) -> void:
	max_health = maxf(1.0, new_max_health)
	if refill:
		current_health = max_health
	else:
		current_health = clampf(current_health, 0.0, max_health)

func apply_damage(amount: float) -> float:
	if amount <= 0.0 or current_health <= 0.0:
		return 0.0
	var before := current_health
	current_health = maxf(0.0, current_health - amount)
	var applied := before - current_health
	damaged.emit(applied, current_health)
	if current_health <= 0.0:
		died.emit()
	return applied

func apply_heal(amount: float) -> float:
	if amount <= 0.0 or current_health <= 0.0:
		return 0.0
	var before := current_health
	current_health = minf(max_health, current_health + amount)
	var applied := current_health - before
	if applied > 0.0:
		healed.emit(applied, current_health)
	return applied

func reset() -> void:
	current_health = max_health

func is_dead() -> bool:
	return current_health <= 0.0

func ratio() -> float:
	return current_health / max_health
