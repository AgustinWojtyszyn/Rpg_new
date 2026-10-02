extends RefCounted

func run() -> Array[String]:
	var failures: Array[String] = []

	var fresh := MetaProgression.new()
	for id_value in MetaProgression.BASE_UNLOCKS:
		if not fresh.is_weapon_unlocked(id_value):
			failures.append("Fresh profile is missing base weapon: %s" % String(id_value))
	if fresh.is_weapon_unlocked(&"bone_rail"):
		failures.append("Bone Rail should require progression on a fresh profile.")

	var essence_profile := MetaProgression.new()
	essence_profile.apply_serialized({
		"lifetime_essence": 60,
		"completed_runs": 0,
		"total_runs": 1,
		"unlocked_weapon_ids": ["rift_sidearm", "raptor_scatter", "spore_repeater"],
	})
	if not essence_profile.is_weapon_unlocked(&"bone_rail"):
		failures.append("Bone Rail must unlock at 60 lifetime essence.")

	var victory_profile := MetaProgression.new()
	victory_profile.apply_serialized({
		"lifetime_essence": 20,
		"completed_runs": 1,
		"total_runs": 1,
		"unlocked_weapon_ids": ["rift_sidearm", "raptor_scatter", "spore_repeater"],
	})
	if not victory_profile.is_weapon_unlocked(&"beetle_core"):
		failures.append("Beetle Core must unlock after the first completed run.")

	var valid_snapshot := {
		"version": RunSaveStore.SAVE_VERSION,
		"seed": 123,
		"current_room_id": 2,
		"cleared_room_ids": [0, 1],
		"rewarded_room_ids": [1],
		"build": RunBuild.new().serialize(),
	}
	if not RunSaveStore.is_valid_snapshot(valid_snapshot):
		failures.append("A well-formed run snapshot must validate.")

	var invalid_snapshot := valid_snapshot.duplicate(true)
	invalid_snapshot["seed"] = 0
	if RunSaveStore.is_valid_snapshot(invalid_snapshot):
		failures.append("Run snapshots with seed 0 must be rejected.")

	return failures
