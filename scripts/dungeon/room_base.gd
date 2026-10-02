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

func setup_base(data: Dictionary, run_player: PlayerCharacter, initially_cleared: bool) -> void:
	room_data = data
	player = run_player
	is_cleared = initially_cleared
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

func _draw() -> void:
	var kind := StringName(room_data.get("kind", &"combat"))
	var floor_color := Color(0.065, 0.075, 0.105)
	match kind:
		&"start":
			floor_color = Color(0.055, 0.105, 0.14)
		&"event":
			floor_color = Color(0.11, 0.07, 0.15)
		&"treasure":
			floor_color = Color(0.14, 0.105, 0.045)
		&"miniboss":
			floor_color = Color(0.13, 0.075, 0.045)
		&"boss":
			floor_color = Color(0.10, 0.045, 0.13)

	draw_rect(Rect2(0, 0, 960, 540), floor_color, true)
	for x in range(64, 960, 64):
		draw_line(Vector2(x, 0), Vector2(x, 540), floor_color.lightened(0.09), 1.0)
	for y in range(64, 540, 64):
		draw_line(Vector2(0, y), Vector2(960, y), floor_color.lightened(0.09), 1.0)
	draw_rect(Rect2(24, 24, 912, 492), floor_color.lightened(0.35), false, 3.0)

	var label := String(kind).to_upper()
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(420, 62), label, HORIZONTAL_ALIGNMENT_CENTER, 120, 18, Color(1, 1, 1, 0.34))
