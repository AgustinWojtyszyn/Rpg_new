extends RefCounted

const EnemyDefinitionScript := preload("res://scripts/data/enemy_definition.gd")
const EncounterDirectorScript := preload("res://scripts/encounters/encounter_director.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var pool: Array[EnemyDefinition] = [
		_make_enemy(&"raptor", EnemyDefinition.Role.CHASER, 3),
		_make_enemy(&"vine", EnemyDefinition.Role.CONTROLLER, 4),
		_make_enemy(&"alien", EnemyDefinition.Role.RANGED, 3),
		_make_enemy(&"beetle", EnemyDefinition.Role.TANK, 5),
		_make_enemy(&"skeleton", EnemyDefinition.Role.CHASER, 2),
	]

	var first_rng := RandomNumberGenerator.new()
	first_rng.seed = 9001
	var second_rng := RandomNumberGenerator.new()
	second_rng.seed = 9001

	var director := EncounterDirectorScript.new()
	var first := director.build_encounter(pool, 12, first_rng, 8)
	var second := director.build_encounter(pool, 12, second_rng, 8)
	if _ids(first) != _ids(second):
		failures.append("Encounter generation must be deterministic for equal RNG state.")
		return failures

	for seed_value in range(1, 301):
		for budget in range(1, 21):
			var rng := RandomNumberGenerator.new()
			rng.seed = seed_value
			var encounter := director.build_encounter(pool, budget, rng, 8)
			var total_cost := 0
			var controller_count := 0
			var tank_count := 0
			for enemy in encounter:
				total_cost += enemy.encounter_cost
				if enemy.role == EnemyDefinition.Role.CONTROLLER:
					controller_count += 1
				elif enemy.role == EnemyDefinition.Role.TANK:
					tank_count += 1

			if total_cost > budget:
				failures.append("Seed %d budget %d: encounter exceeded budget." % [seed_value, budget])
				return failures
			if encounter.size() > 8:
				failures.append("Seed %d budget %d: encounter exceeded unit cap." % [seed_value, budget])
				return failures
			if controller_count > 1:
				failures.append("Seed %d budget %d: controller cap failed." % [seed_value, budget])
				return failures
			if tank_count > 2:
				failures.append("Seed %d budget %d: tank cap failed." % [seed_value, budget])
				return failures

	return failures

func _make_enemy(id_value: StringName, role_value: EnemyDefinition.Role, cost: int) -> EnemyDefinition:
	var definition := EnemyDefinitionScript.new() as EnemyDefinition
	definition.id = id_value
	definition.role = role_value
	definition.encounter_cost = cost
	return definition

func _ids(definitions: Array[EnemyDefinition]) -> Array[StringName]:
	var result: Array[StringName] = []
	for definition in definitions:
		result.append(definition.id)
	return result
