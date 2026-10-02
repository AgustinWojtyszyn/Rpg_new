class_name RewardDirector
extends RefCounted

func build_treasure_options(
	build: RunBuild,
	rng: RandomNumberGenerator,
	available_weapon_ids: Array[StringName],
	count: int = 3
) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	var weapon_pool: Array[WeaponDefinition] = []
	for definition in WeaponCatalog.all():
		if not available_weapon_ids.has(definition.id):
			continue
		if build.weapon != null and definition.id == build.weapon.id:
			continue
		weapon_pool.append(definition)

	var modifier_pool: Array[RunModifierDefinition] = []
	for definition in RunModifierCatalog.all():
		if not build.has_modifier(definition.id):
			modifier_pool.append(definition)

	if not weapon_pool.is_empty() and count > 0:
		var weapon := _weighted_weapon_pick(weapon_pool, rng)
		options.append(_weapon_option(weapon))
		weapon_pool.erase(weapon)

	while options.size() < count:
		var use_weapon := not weapon_pool.is_empty() and (modifier_pool.is_empty() or rng.randf() < 0.42)
		if use_weapon:
			var weapon := _weighted_weapon_pick(weapon_pool, rng)
			options.append(_weapon_option(weapon))
			weapon_pool.erase(weapon)
		elif not modifier_pool.is_empty():
			var modifier := _weighted_modifier_pick(modifier_pool, rng)
			options.append(_modifier_option(modifier))
			modifier_pool.erase(modifier)
		else:
			break

	return options

func build_event(
	build: RunBuild,
	rng: RandomNumberGenerator,
	available_weapon_ids: Array[StringName]
) -> Dictionary:
	var event_index := rng.randi_range(0, 4)
	match event_index:
		0:
			return {
				"title": "Nido fósil",
				"description": "Algo sigue latiendo dentro de la piedra.",
				"options": [
					_effect_option("Consumir médula", "Recupera 42 de vida.", &"heal", {"amount": 42.0}),
					_modifier_or_essence(build, &"predator_sigil", "Absorber instinto", 24),
				],
			}
		1:
			return {
				"title": "Consola alienígena",
				"description": "La máquina ofrece potencia o conocimiento.",
				"options": [
					_random_weapon_option(build, rng, available_weapon_ids, "Reescribir arma", 22),
					_effect_option("Extraer esencia", "+30 esencia.", &"essence", {"amount": 30}),
				],
			}
		2:
			return {
				"title": "Santuario de raíces",
				"description": "Las raíces responden al pulso del jugador.",
				"options": [
					_effect_option("Descansar", "Recupera 60 de vida.", &"heal", {"amount": 60.0}),
					_modifier_or_essence(build, &"mycelial_heart", "Aceptar simbiosis", 26),
				],
			}
		3:
			return {
				"title": "Forja del caparazón",
				"description": "Metal orgánico aún caliente.",
				"options": [
					_modifier_or_essence(build, &"beetle_carapace", "Fundir armadura", 25),
					_effect_option("Vender fragmentos", "+28 esencia.", &"essence", {"amount": 28}),
				],
			}
		_:
			return {
				"title": "Fractura temporal",
				"description": "Un segundo parece durar demasiado.",
				"options": [
					_modifier_or_essence(build, &"chrono_tendon", "Entrar en la fractura", 27),
					_modifier_or_essence(build, &"void_capacitor", "Robar energía del vacío", 27),
				],
			}

func _random_weapon_option(
	build: RunBuild,
	rng: RandomNumberGenerator,
	available_weapon_ids: Array[StringName],
	fallback_title: String,
	fallback_essence: int
) -> Dictionary:
	var candidates: Array[WeaponDefinition] = []
	for definition in WeaponCatalog.all():
		if not available_weapon_ids.has(definition.id):
			continue
		if build.weapon != null and definition.id == build.weapon.id:
			continue
		candidates.append(definition)

	if candidates.is_empty():
		return _effect_option(fallback_title, "+%d esencia." % fallback_essence, &"essence", {"amount": fallback_essence})

	var weapon := _weighted_weapon_pick(candidates, rng)
	return _weapon_option(weapon, fallback_title)

func _modifier_or_essence(
	build: RunBuild,
	modifier_id: StringName,
	action_title: String,
	fallback_essence: int
) -> Dictionary:
	var modifier := RunModifierCatalog.get_by_id(modifier_id)
	if modifier != null and not build.has_modifier(modifier_id):
		return {
			"kind": &"modifier",
			"title": action_title,
			"name": modifier.display_name,
			"description": modifier.description,
			"id": modifier.id,
			"resource": modifier,
		}
	return _effect_option(action_title, "+%d esencia porque ya poseés esta mutación." % fallback_essence, &"essence", {"amount": fallback_essence})

func _weapon_option(definition: WeaponDefinition, action_title: String = "") -> Dictionary:
	return {
		"kind": &"weapon",
		"title": action_title if not action_title.is_empty() else definition.display_name,
		"name": definition.display_name,
		"description": definition.description,
		"id": definition.id,
		"resource": definition,
	}

func _modifier_option(definition: RunModifierDefinition) -> Dictionary:
	return {
		"kind": &"modifier",
		"title": definition.display_name,
		"name": definition.display_name,
		"description": definition.description,
		"id": definition.id,
		"resource": definition,
	}

func _effect_option(
	title: String,
	description: String,
	effect: StringName,
	payload: Dictionary
) -> Dictionary:
	return {
		"kind": &"effect",
		"title": title,
		"name": title,
		"description": description,
		"effect": effect,
		"payload": payload,
	}

func _weighted_weapon_pick(pool: Array[WeaponDefinition], rng: RandomNumberGenerator) -> WeaponDefinition:
	var total := 0.0
	for definition in pool:
		total += definition.reward_weight
	var roll := rng.randf_range(0.0, total)
	var cursor := 0.0
	for definition in pool:
		cursor += definition.reward_weight
		if roll <= cursor:
			return definition
	return pool.back()

func _weighted_modifier_pick(pool: Array[RunModifierDefinition], rng: RandomNumberGenerator) -> RunModifierDefinition:
	var total := 0.0
	for definition in pool:
		total += definition.reward_weight
	var roll := rng.randf_range(0.0, total)
	var cursor := 0.0
	for definition in pool:
		cursor += definition.reward_weight
		if roll <= cursor:
			return definition
	return pool.back()
