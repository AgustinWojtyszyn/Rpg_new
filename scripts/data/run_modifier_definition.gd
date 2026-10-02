class_name RunModifierDefinition
extends Resource

@export var id: StringName
@export var display_name: String = "Modifier"
@export_multiline var description: String = ""
@export_range(-0.9, 5.0, 0.01) var damage_bonus: float = 0.0
@export_range(-0.9, 5.0, 0.01) var fire_rate_bonus: float = 0.0
@export_range(-0.9, 5.0, 0.01) var move_speed_bonus: float = 0.0
@export_range(-0.9, 5.0, 0.01) var projectile_speed_bonus: float = 0.0
@export_range(0, 4, 1) var projectile_count_bonus: int = 0
@export_range(-0.9, 5.0, 0.01) var max_health_bonus: float = 0.0
@export_range(-0.9, 5.0, 0.01) var dash_recharge_bonus: float = 0.0
@export_range(0.0, 1.5, 0.01) var hurt_invulnerability_bonus: float = 0.0
@export_range(0.0, 3.0, 0.01) var explosion_radius_bonus: float = 0.0
@export_range(0.0, 200.0, 1.0) var heal_on_pickup: float = 0.0
@export_range(0.01, 100.0, 0.01) var reward_weight: float = 1.0
