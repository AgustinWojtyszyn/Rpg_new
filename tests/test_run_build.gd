extends RefCounted

func run() -> Array[String]:
	var failures: Array[String] = []
	var weapons := WeaponCatalog.all()
	var modifiers := RunModifierCatalog.all()

	if weapons.size() < 5:
		failures.append("Iteration 2 requires at least five weapon definitions.")
	if modifiers.size() < 6:
		failures.append("Iteration 2 requires at least six run modifiers.")

	_validate_weapon_ids(weapons, failures)
	_validate_weapon_mechanics(weapons, failures)
	_validate_modifier_ids(modifiers, failures)
	_validate_build_math(failures)
	_validate_serialization(failures)
	return failures

func _validate_weapon_ids(weapons: Array[WeaponDefinition], failures: Array[String]) -> void:
	var ids: Dictionary = {}
	for definition in weapons:
		if definition == null or definition.id == &"":
			failures.append("Every weapon requires a non-empty id.")
			return
		if ids.has(definition.id):
			failures.append("Duplicate weapon id: %s" % String(definition.id))
			return
		ids[definition.id] = true
		if definition.damage <= 0.0 or definition.fire_cooldown <= 0.0:
			failures.append("Weapon %s has invalid combat values." % String(definition.id))
			return

func _validate_weapon_mechanics(weapons: Array[WeaponDefinition], failures: Array[String]) -> void:
	var signatures: Dictionary = {}
	for definition in weapons:
		var signature := "%d|%.1f|%d|%d|%.1f" % [
			definition.projectile_count,
			definition.spread_degrees,
			definition.burst_count,
			definition.pierce_count,
			definition.explosion_radius,
		]
		if signatures.has(signature):
			failures.append("Weapons must not collapse into identical mechanic signatures: %s" % signature)
			return
		signatures[signature] = true

func _validate_modifier_ids(modifiers: Array[RunModifierDefinition], failures: Array[String]) -> void:
	var ids: Dictionary = {}
	for definition in modifiers:
		if definition == null or definition.id == &"":
			failures.append("Every modifier requires a non-empty id.")
			return
		if ids.has(definition.id):
			failures.append("Duplicate modifier id: %s" % String(definition.id))
			return
		ids[definition.id] = true

func _validate_build_math(failures: Array[String]) -> void:
	var build := RunBuild.new()
	var predator := RunModifierCatalog.get_by_id(&"predator_sigil")
	var lens := RunModifierCatalog.get_by_id(&"alien_lens")
	if not build.add_modifier(predator):
		failures.append("First modifier pickup should succeed.")
		return
	if build.add_modifier(predator):
		failures.append("Duplicate modifiers must be rejected.")
		return
	if not build.add_modifier(lens):
		failures.append("Second unique modifier should succeed.")
		return
	if build.damage_multiplier() <= 1.0:
		failures.append("Predator Sigil must increase damage.")
	if build.projectile_count_bonus() != 1:
		failures.append("Alien Lens must add exactly one projectile.")

func _validate_serialization(failures: Array[String]) -> void:
	var build := RunBuild.new()
	build.equip_weapon(WeaponCatalog.get_by_id(&"bone_rail"))
	build.add_modifier(RunModifierCatalog.get_by_id(&"chrono_tendon"))
	build.add_modifier(RunModifierCatalog.get_by_id(&"beetle_carapace"))
	build.add_essence(37)
	var restored := RunBuild.deserialize(build.serialize())
	if restored.weapon == null or restored.weapon.id != &"bone_rail":
		failures.append("RunBuild serialization must preserve equipped weapon.")
	if not restored.has_modifier(&"chrono_tendon") or not restored.has_modifier(&"beetle_carapace"):
		failures.append("RunBuild serialization must preserve modifier ids.")
	if restored.essence != 37:
		failures.append("RunBuild serialization must preserve essence.")
