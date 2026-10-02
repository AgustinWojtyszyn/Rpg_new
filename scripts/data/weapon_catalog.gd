class_name WeaponCatalog
extends RefCounted

const WEAPONS: Array[WeaponDefinition] = [
	preload("res://resources/weapons/rift_sidearm.tres"),
	preload("res://resources/weapons/raptor_scatter.tres"),
	preload("res://resources/weapons/bone_rail.tres"),
	preload("res://resources/weapons/spore_repeater.tres"),
	preload("res://resources/weapons/beetle_core.tres"),
]

static func all() -> Array[WeaponDefinition]:
	return WEAPONS.duplicate()

static func get_by_id(id_value: StringName) -> WeaponDefinition:
	for definition in WEAPONS:
		if definition.id == id_value:
			return definition
	return null

static func default_weapon() -> WeaponDefinition:
	return WEAPONS[0]
