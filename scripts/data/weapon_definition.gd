class_name WeaponDefinition
extends Resource

@export var id: StringName
@export var display_name: String = "Weapon"
@export_multiline var description: String = ""
@export_range(0.1, 500.0, 0.1) var damage: float = 12.0
@export_range(0.05, 5.0, 0.01) var fire_cooldown: float = 0.28
@export_range(50.0, 2000.0, 1.0) var projectile_speed: float = 520.0
@export_range(0.1, 6.0, 0.05) var projectile_lifetime: float = 1.4
@export_range(1, 12, 1) var projectile_count: int = 1
@export_range(0.0, 120.0, 1.0) var spread_degrees: float = 0.0
@export_range(1, 8, 1) var burst_count: int = 1
@export_range(0.02, 1.0, 0.01) var burst_interval: float = 0.10
@export_range(0, 8, 1) var pierce_count: int = 0
@export_range(0.0, 180.0, 1.0) var explosion_radius: float = 0.0
@export_range(2.0, 18.0, 0.5) var projectile_radius: float = 4.5
@export_range(0.01, 100.0, 0.01) var reward_weight: float = 1.0
@export var projectile_color: Color = Color(1.0, 0.78, 0.20)
