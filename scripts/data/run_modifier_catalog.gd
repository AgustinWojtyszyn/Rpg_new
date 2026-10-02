class_name RunModifierCatalog
extends RefCounted

const MODIFIERS: Array[RunModifierDefinition] = [
	preload("res://resources/modifiers/predator_sigil.tres"),
	preload("res://resources/modifiers/mycelial_heart.tres"),
	preload("res://resources/modifiers/alien_lens.tres"),
	preload("res://resources/modifiers/beetle_carapace.tres"),
	preload("res://resources/modifiers/chrono_tendon.tres"),
	preload("res://resources/modifiers/void_capacitor.tres"),
]

static func all() -> Array[RunModifierDefinition]:
	return MODIFIERS.duplicate()

static func get_by_id(id_value: StringName) -> RunModifierDefinition:
	for definition in MODIFIERS:
		if definition.id == id_value:
			return definition
	return null
