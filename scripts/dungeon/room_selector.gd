class_name RoomSelector
extends RefCounted

func choose(
	pool: Array[RoomDefinition],
	kind: StringName,
	depth: int,
	rng: RandomNumberGenerator
) -> RoomDefinition:
	var candidates: Array[RoomDefinition] = []
	var total_weight := 0.0

	for definition in pool:
		if definition == null:
			continue
		if definition.kind != kind:
			continue
		if not definition.supports_depth(depth):
			continue
		if definition.weight <= 0.0:
			continue
		candidates.append(definition)
		total_weight += definition.weight

	if candidates.is_empty():
		return null

	var roll := rng.randf_range(0.0, total_weight)
	var cursor := 0.0
	for definition in candidates:
		cursor += definition.weight
		if roll <= cursor:
			return definition

	return candidates.back()
