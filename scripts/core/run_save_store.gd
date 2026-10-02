class_name RunSaveStore
extends RefCounted

const SAVE_VERSION := 1
const SAVE_PATH := "user://rpg_new_run.json"

static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func save_snapshot(snapshot: Dictionary) -> bool:
	var payload := snapshot.duplicate(true)
	payload["version"] = SAVE_VERSION
	if not is_valid_snapshot(payload):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload))
	file.close()
	return true

static func load_snapshot() -> Dictionary:
	if not has_save():
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var raw := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(raw)
	if parsed is not Dictionary:
		return {}

	var data := parsed as Dictionary
	return data if is_valid_snapshot(data) else {}

static func is_valid_snapshot(data: Dictionary) -> bool:
	if int(data.get("version", SAVE_VERSION)) != SAVE_VERSION:
		return false
	if int(data.get("seed", 0)) == 0:
		return false
	if int(data.get("current_room_id", -1)) < 0:
		return false
	if data.get("build", null) is not Dictionary:
		return false
	if data.get("cleared_room_ids", null) is not Array:
		return false
	if data.get("rewarded_room_ids", null) is not Array:
		return false
	return true

static func clear() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
