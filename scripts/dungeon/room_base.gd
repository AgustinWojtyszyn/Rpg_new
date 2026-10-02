class_name RoomBase
extends Node2D

signal door_traversed(destination_room_id: int, exit_slot: StringName)
signal room_cleared

const ROOM_DOOR_SCENE := preload("res://scenes/dungeon/room_door.tscn")

const SLOT_POSITIONS := {
	&"north": Vector2(480, 34),
	&"south": Vector2(480, 506),
	&"east": Vector2(926, 270),
	&"west": Vector2(34, 270),
}

const ENTRY_POSITIONS := {
	&"north": Vector2(480, 92),
	&"south": Vector2(480, 448),
	&"east": Vector2(866, 270),
	&"west": Vector2(94, 270),
}

var room_data: Dictionary = {}
var player: PlayerCharacter
var is_cleared: bool = false
var _doors: Array[RoomDoor] = []
var _decor_points: Array[Vector2] = []

func setup_base(data: Dictionary, run_player: PlayerCharacter, initially_cleared: bool) -> void:
	room_data = data
	player = run_player
	is_cleared = initially_cleared
	_prepare_decor()
	_build_doors()
	queue_redraw()

func mark_cleared() -> void:
	if is_cleared:
		return
	is_cleared = true
	for door in _doors:
		door.set_active(true)
	room_cleared.emit()
	queue_redraw()

func spawn_position_for_entry(entry_slot: StringName) -> Vector2:
	if ENTRY_POSITIONS.has(entry_slot):
		return ENTRY_POSITIONS[entry_slot]
	return Vector2(480, 270)

func get_boss() -> BossBase:
	return null

func _prepare_decor() -> void:
	_decor_points.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = (
		(int(room_data.get("id", 0)) + 1) * 7919
		+ (int(room_data.get("depth", 0)) + 1) * 104729
	)
	for _index in range(14):
		_decor_points.append(Vector2(
			rng.randf_range(78.0, 882.0),
			rng.randf_range(104.0, 462.0)
		))

func _build_doors() -> void:
	var doors_data: Dictionary = room_data.get("doors", {})
	for slot_variant in doors_data:
		var slot := StringName(slot_variant)
		if not SLOT_POSITIONS.has(slot):
			continue
		var door := ROOM_DOOR_SCENE.instantiate() as RoomDoor
		door.position = SLOT_POSITIONS[slot]
		door.configure(slot, int(doors_data[slot_variant]), is_cleared)
		door.traversed.connect(_on_door_traversed)
		add_child(door)
		_doors.append(door)

func _on_door_traversed(destination_room_id: int, exit_slot: StringName) -> void:
	door_traversed.emit(destination_room_id, exit_slot)

func _palette_for_kind(kind: StringName) -> Dictionary:
	match kind:
		&"start":
			return {"floor": Color(0.045, 0.09, 0.13), "accent": Color(0.24, 0.82, 1.0)}
		&"event":
			return {"floor": Color(0.09, 0.045, 0.13), "accent": Color(0.72, 0.38, 1.0)}
		&"treasure":
			return {"floor": Color(0.13, 0.085, 0.035), "accent": Color(1.0, 0.70, 0.20)}
		&"miniboss":
			return {"floor": Color(0.12, 0.055, 0.03), "accent": Color(1.0, 0.34, 0.12)}
		&"boss":
			return {"floor": Color(0.075, 0.025, 0.11), "accent": Color(0.90, 0.22, 1.0)}
		_:
			return {"floor": Color(0.045, 0.055, 0.08), "accent": Color(0.30, 0.58, 0.92)}

func _draw() -> void:
	var kind := StringName(room_data.get("kind", &"combat"))
	var palette := _palette_for_kind(kind)
	var floor: Color = palette["floor"]
	var accent: Color = palette["accent"]

	draw_rect(Rect2(0, 0, 960, 540), floor.darkened(0.36), true)
	draw_rect(Rect2(24, 24, 912, 492), floor, true)

	for x in range(48, 936, 48):
		draw_line(Vector2(x, 24), Vector2(x, 516), Color(accent, 0.045), 1.0)
	for y in range(48, 516, 48):
		draw_line(Vector2(24, y), Vector2(936, y), Color(accent, 0.045), 1.0)

	for index in range(_decor_points.size()):
		var point := _decor_points[index]
		var radius := 3.0 + float(index % 3)
		draw_circle(point, radius + 2.0, Color(0.0, 0.0, 0.0, 0.20))
		draw_circle(point, radius, Color(accent, 0.13))
		if index % 4 == 0:
			draw_line(point + Vector2(-9, 5), point + Vector2(8, -4), Color(accent, 0.12), 2.0)
			draw_line(point + Vector2(8, -4), point + Vector2(13, 3), Color(accent, 0.08), 1.0)

	var doors_data: Dictionary = room_data.get("doors", {})
	if doors_data.has(&"north"):
		draw_rect(Rect2(444, 24, 72, 72), Color(accent, 0.08), true)
	if doors_data.has(&"south"):
		draw_rect(Rect2(444, 444, 72, 72), Color(accent, 0.08), true)
	if doors_data.has(&"west"):
		draw_rect(Rect2(24, 234, 72, 72), Color(accent, 0.08), true)
	if doors_data.has(&"east"):
		draw_rect(Rect2(864, 234, 72, 72), Color(accent, 0.08), true)

	draw_rect(Rect2(24, 24, 912, 492), Color(accent, 0.58), false, 3.0)
	draw_rect(Rect2(31, 31, 898, 478), Color(accent, 0.11), false, 1.0)

	for corner in [
		Vector2(48, 48),
		Vector2(912, 48),
		Vector2(48, 492),
		Vector2(912, 492),
	]:
		draw_circle(corner, 8.0, Color(accent, 0.26))
		draw_arc(corner, 14.0, 0.0, TAU, 16, Color(accent, 0.30), 2.0)

	var label := String(kind).to_upper()
	var font := ThemeDB.fallback_font
	draw_string(
		font,
		Vector2(420, 62),
		label,
		HORIZONTAL_ALIGNMENT_CENTER,
		120,
		17,
		Color(accent, 0.58)
	)
