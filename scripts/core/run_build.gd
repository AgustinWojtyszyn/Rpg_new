class_name RunBuild
extends RefCounted

signal changed

var weapon: WeaponDefinition = WeaponCatalog.default_weapon()
var modifiers: Array[RunModifierDefinition] = []
var essence: int = 0

func equip_weapon(definition: WeaponDefinition) -> bool:
	if definition == null:
		return false
	weapon = definition
	changed.emit()
	return true

func add_modifier(definition: RunModifierDefinition) -> bool:
	if definition == null or has_modifier(definition.id):
		return false
	modifiers.append(definition)
	changed.emit()
	return true

func has_modifier(id_value: StringName) -> bool:
	for definition in modifiers:
		if definition.id == id_value:
			return true
	return false

func add_essence(amount: int) -> int:
	if amount <= 0:
		return essence
	essence += amount
	changed.emit()
	return essence

func spend_essence(amount: int) -> bool:
	if amount <= 0 or essence < amount:
		return false
	essence -= amount
	changed.emit()
	return true

func damage_multiplier() -> float:
	var value := 1.0
	for definition in modifiers:
		value += definition.damage_bonus
	return maxf(0.1, value)

func fire_cooldown_multiplier() -> float:
	var fire_rate := 1.0
	for definition in modifiers:
		fire_rate += definition.fire_rate_bonus
	return 1.0 / maxf(0.15, fire_rate)

func move_speed_multiplier() -> float:
	var value := 1.0
	for definition in modifiers:
		value += definition.move_speed_bonus
	return maxf(0.2, value)

func projectile_speed_multiplier() -> float:
	var value := 1.0
	for definition in modifiers:
		value += definition.projectile_speed_bonus
	return maxf(0.2, value)

func projectile_count_bonus() -> int:
	var value := 0
	for definition in modifiers:
		value += definition.projectile_count_bonus
	return value

func max_health_multiplier() -> float:
	var value := 1.0
	for definition in modifiers:
		value += definition.max_health_bonus
	return maxf(0.2, value)

func dash_cooldown_multiplier() -> float:
	var recharge := 1.0
	for definition in modifiers:
		recharge += definition.dash_recharge_bonus
	return 1.0 / maxf(0.15, recharge)

func hurt_invulnerability_bonus() -> float:
	var value := 0.0
	for definition in modifiers:
		value += definition.hurt_invulnerability_bonus
	return value

func explosion_radius_multiplier() -> float:
	var value := 1.0
	for definition in modifiers:
		value += definition.explosion_radius_bonus
	return maxf(0.1, value)

func serialize() -> Dictionary:
	var modifier_ids: Array[String] = []
	for definition in modifiers:
		modifier_ids.append(String(definition.id))
	return {
		"weapon_id": String(weapon.id if weapon != null else WeaponCatalog.default_weapon().id),
		"modifier_ids": modifier_ids,
		"essence": essence,
	}

static func deserialize(data: Dictionary) -> RunBuild:
	var build := RunBuild.new()
	var weapon_id := StringName(data.get("weapon_id", String(WeaponCatalog.default_weapon().id)))
	var restored_weapon := WeaponCatalog.get_by_id(weapon_id)
	if restored_weapon != null:
		build.weapon = restored_weapon

	for raw_id in data.get("modifier_ids", []):
		var modifier := RunModifierCatalog.get_by_id(StringName(raw_id))
		if modifier != null and not build.has_modifier(modifier.id):
			build.modifiers.append(modifier)

	build.essence = maxi(0, int(data.get("essence", 0)))
	return build
