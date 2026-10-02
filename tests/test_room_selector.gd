extends RefCounted

const RoomDefinitionScript := preload("res://scripts/data/room_definition.gd")
const RoomSelectorScript := preload("res://scripts/dungeon/room_selector.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var shallow := _make_room(&"shallow", &"combat", 0, 2, 1.0)
	var deep := _make_room(&"deep", &"combat", 3, 10, 1.0)
	var treasure := _make_room(&"treasure", &"treasure", 0, 10, 1.0)
	var pool: Array[RoomDefinition] = [shallow, deep, treasure]

	var first_rng := RandomNumberGenerator.new()
	first_rng.seed = 77
	var second_rng := RandomNumberGenerator.new()
	second_rng.seed = 77

	var selector := RoomSelectorScript.new()
	var first: RoomDefinition = selector.choose(pool, &"combat", 1, first_rng)
	var second: RoomDefinition = selector.choose(pool, &"combat", 1, second_rng)

	if first == null or first.id != &"shallow":
		failures.append("Room selector must enforce depth constraints.")
	if second == null or first.id != second.id:
		failures.append("Room selection must be deterministic for equal RNG state.")
	if selector.choose(pool, &"boss", 1, first_rng) != null:
		failures.append("Room selector must return null when no room is compatible.")

	return failures

func _make_room(
	id_value: StringName,
	kind_value: StringName,
	minimum: int,
	maximum: int,
	weight_value: float
) -> RoomDefinition:
	var definition := RoomDefinitionScript.new() as RoomDefinition
	definition.id = id_value
	definition.kind = kind_value
	definition.min_depth = minimum
	definition.max_depth = maximum
	definition.weight = weight_value
	return definition
