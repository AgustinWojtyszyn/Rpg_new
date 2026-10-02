extends RefCounted

func run() -> Array[String]:
	var failures: Array[String] = []
	var director := RewardDirector.new()
	var build := RunBuild.new()
	var weapon_ids: Array[StringName] = []
	for weapon in WeaponCatalog.all():
		weapon_ids.append(weapon.id)

	var first_rng := RandomNumberGenerator.new()
	first_rng.seed = 481516
	var second_rng := RandomNumberGenerator.new()
	second_rng.seed = 481516

	var first := director.build_treasure_options(build, first_rng, weapon_ids, 3)
	var second := director.build_treasure_options(build, second_rng, weapon_ids, 3)

	if _signature(first) != _signature(second):
		failures.append("Treasure rewards must be deterministic for equal RNG state.")
	if first.size() != 3:
		failures.append("Treasure rooms should expose three options while the catalog has capacity.")
	if _has_duplicate_ids(first):
		failures.append("Treasure options must not repeat the same reward id.")

	var maxed_build := RunBuild.new()
	for modifier in RunModifierCatalog.all():
		maxed_build.add_modifier(modifier)
	var maxed_rng := RandomNumberGenerator.new()
	maxed_rng.seed = 98
	var maxed_options := director.build_treasure_options(maxed_build, maxed_rng, weapon_ids, 3)
	if maxed_options.size() != 3:
		failures.append("Treasure rooms must still provide three choices for a maxed build.")

	build.add_modifier(RunModifierCatalog.get_by_id(&"predator_sigil"))
	var event_rng := RandomNumberGenerator.new()
	event_rng.seed = 1
	for _index in range(20):
		var event := director.build_event(build, event_rng, weapon_ids)
		var options = event.get("options", [])
		if options.size() != 2:
			failures.append("Every event must expose exactly two decisions.")
			break

	return failures

func _signature(options: Array[Dictionary]) -> Array[String]:
	var result: Array[String] = []
	for option in options:
		result.append("%s:%s" % [
			String(option.get("kind", "")),
			String(option.get("id", option.get("effect", ""))),
		])
	return result

func _has_duplicate_ids(options: Array[Dictionary]) -> bool:
	var seen: Dictionary = {}
	for option in options:
		var id_value := String(option.get("id", ""))
		if id_value.is_empty():
			continue
		if seen.has(id_value):
			return true
		seen[id_value] = true
	return false
