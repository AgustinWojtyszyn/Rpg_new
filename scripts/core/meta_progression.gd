class_name MetaProgression
extends RefCounted

const PROFILE_VERSION := 1
const PROFILE_PATH := "user://rpg_new_profile.json"

const BASE_UNLOCKS: Array[StringName] = [
	&"rift_sidearm",
	&"raptor_scatter",
	&"spore_repeater",
]

var lifetime_essence: int = 0
var completed_runs: int = 0
var total_runs: int = 0
var unlocked_weapon_ids: Array[StringName] = []

func _init() -> void:
	_ensure_base_unlocks()

func record_run(victory: bool, run_essence: int) -> Array[StringName]:
	total_runs += 1
	lifetime_essence += maxi(0, run_essence)
	if victory:
		completed_runs += 1
	var newly_unlocked := _refresh_unlocks()
	save()
	return newly_unlocked

func is_weapon_unlocked(id_value: StringName) -> bool:
	return unlocked_weapon_ids.has(id_value)

func get_unlocked_weapon_ids() -> Array[StringName]:
	return unlocked_weapon_ids.duplicate()

func serialize() -> Dictionary:
	var weapon_ids: Array[String] = []
	for id_value in unlocked_weapon_ids:
		weapon_ids.append(String(id_value))
	return {
		"version": PROFILE_VERSION,
		"lifetime_essence": lifetime_essence,
		"completed_runs": completed_runs,
		"total_runs": total_runs,
		"unlocked_weapon_ids": weapon_ids,
	}

func apply_serialized(data: Dictionary) -> void:
	lifetime_essence = maxi(0, int(data.get("lifetime_essence", 0)))
	completed_runs = maxi(0, int(data.get("completed_runs", 0)))
	total_runs = maxi(completed_runs, int(data.get("total_runs", 0)))
	unlocked_weapon_ids.clear()
	for raw_id in data.get("unlocked_weapon_ids", []):
		var id_value := StringName(raw_id)
		if WeaponCatalog.get_by_id(id_value) != null and not unlocked_weapon_ids.has(id_value):
			unlocked_weapon_ids.append(id_value)
	_ensure_base_unlocks()
	_refresh_unlocks()

func save() -> bool:
	var file := FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(serialize()))
	file.close()
	return true

static func load_profile() -> MetaProgression:
	var profile := MetaProgression.new()
	if not FileAccess.file_exists(PROFILE_PATH):
		return profile

	var file := FileAccess.open(PROFILE_PATH, FileAccess.READ)
	if file == null:
		return profile
	var raw := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(raw)
	if parsed is Dictionary:
		var data := parsed as Dictionary
		if int(data.get("version", PROFILE_VERSION)) <= PROFILE_VERSION:
			profile.apply_serialized(data)
	return profile

func _ensure_base_unlocks() -> void:
	for id_value in BASE_UNLOCKS:
		if not unlocked_weapon_ids.has(id_value):
			unlocked_weapon_ids.append(id_value)

func _refresh_unlocks() -> Array[StringName]:
	var newly_unlocked: Array[StringName] = []
	_try_unlock(&"bone_rail", lifetime_essence >= 60, newly_unlocked)
	_try_unlock(&"beetle_core", completed_runs >= 1 or lifetime_essence >= 140, newly_unlocked)
	return newly_unlocked

func _try_unlock(id_value: StringName, condition: bool, newly_unlocked: Array[StringName]) -> void:
	if not condition or unlocked_weapon_ids.has(id_value):
		return
	if WeaponCatalog.get_by_id(id_value) == null:
		return
	unlocked_weapon_ids.append(id_value)
	newly_unlocked.append(id_value)
