class_name EncounterDirector
extends RefCounted

const MAX_ATTEMPTS := 128

func build_encounter(
	pool: Array[EnemyDefinition],
	budget: int,
	rng: RandomNumberGenerator,
	max_units: int = 8
) -> Array[EnemyDefinition]:
	var chosen: Array[EnemyDefinition] = []
	var role_counts: Dictionary = {}
	var remaining := maxi(0, budget)
	var attempts := 0

	while remaining > 0 and chosen.size() < max_units and attempts < MAX_ATTEMPTS:
		attempts += 1
		var candidates: Array[EnemyDefinition] = []
		for definition in pool:
			if definition == null:
				continue
			if definition.encounter_cost > remaining:
				continue
			if not _role_allowed(definition.role, role_counts):
				continue
			candidates.append(definition)

		if candidates.is_empty():
			break

		var pick := candidates[rng.randi_range(0, candidates.size() - 1)]
		chosen.append(pick)
		remaining -= pick.encounter_cost
		role_counts[pick.role] = int(role_counts.get(pick.role, 0)) + 1

	return chosen

func _role_allowed(role: EnemyDefinition.Role, role_counts: Dictionary) -> bool:
	var count := int(role_counts.get(role, 0))
	match role:
		EnemyDefinition.Role.CONTROLLER:
			return count < 1
		EnemyDefinition.Role.TANK:
			return count < 2
		_:
			return true
