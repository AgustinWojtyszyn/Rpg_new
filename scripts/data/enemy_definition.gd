class_name EnemyDefinition
extends Resource

enum Family {
	DINOSAUR,
	PLANT,
	ALIEN,
	SKELETON,
	INSECT,
}

enum Role {
	CHASER,
	RANGED,
	CONTROLLER,
	TANK,
	SWARM,
}

@export var id: StringName
@export var display_name: String = "Enemy"
@export var family: Family = Family.SKELETON
@export var role: Role = Role.CHASER
@export_range(1.0, 10000.0, 1.0) var max_health: float = 30.0
@export_range(0.0, 1000.0, 1.0) var move_speed: float = 100.0
@export_range(0.0, 1000.0, 1.0) var contact_damage: float = 10.0
@export_range(0.0, 1000.0, 1.0) var preferred_range: float = 180.0
@export_range(1, 100, 1) var encounter_cost: int = 2
@export var placeholder_color: Color = Color.WHITE
