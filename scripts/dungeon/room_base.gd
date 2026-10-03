class_name RoomBase
extends Node2D

signal door_traversed(destination_room_id: int, exit_slot: StringName)
signal room_cleared

const ROOM_DOOR_SCENE := preload("res://scenes/dungeon/room_door.tscn")

const STONE_TILESET := preload("res://assets/generated/tiles/stone/stone_dungeon_tileset.png")
const STONE_MOSS_TILESET := preload("res://assets/generated/tiles/stone/stone_moss_floor_tileset.png")
const STONE_BLOOD_TILESET := preload("res://assets/generated/tiles/stone/stone_blood_floor_tileset.png")
const TORCH := preload("res://assets/generated/props/lighting/torch_wall.png")
const BRAZIER := preload("res://assets/generated/props/lighting/brazier.png")
const COLUMN := preload("res://assets/generated/props/structures/stone_column.png")
const BROKEN_COLUMN := preload("res://assets/generated/props/structures/broken_column.png")
const BARREL := preload("res://assets/generated/props/containers/barrel.png")
const CRATE := preload("res://assets/generated/props/containers/crate.png")
const START_MARKER := preload("res://assets/generated/rooms/starting_waystone.png")
const COMBAT_MARKER := preload("res://assets/generated/rooms/combat_scorch_decal.png")
const TREASURE_MARKER := preload("res://assets/generated/rooms/treasure_floor_accent.png")
const EVENT_MARKER := preload("res://assets/generated/rooms/event_rune_circle.png")
const MINIBOSS_MARKER := preload("res://assets/generated/rooms/miniboss_arena_seal.png")
const BOSS_MARKER := preload("res://assets/generated/rooms/boss_arena_seal.png")
const TREASURE_CHEST := preload("res://assets/generated/props/chests/rare_chest.png")

const SLOT_POSITIONS := {
	&"north": Vector2(480, 34),
	&"south": Vector2(480, 506),
	&"east": Vector2(926, 270),
	&"west": Vector2(34, 270),
}

const ENTRY_POSITIONS := {
	&"north": Vector2(480, 104),
	&"south": Vector2(480, 436),
	&"east": Vector2(852, 270),
	&"west": Vector2(108, 270),
}

var room_data: Dictionary = {}
var player: PlayerCharacter
var is_cleared: bool = false
var _doors: Array[RoomDoor] = []
var _art_props: Node2D

func setup_base(data: Dictionary, run_player: PlayerCharacter, initially_cleared: bool) -> void:
	room_data = data
	player = run_player
	is_cleared = initially_cleared
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_art_props()
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

func _build_art_props() -> void:
	if is_instance_valid(_art_props):
		_art_props.queue_free()

	_art_props = Node2D.new()
	_art_props.name = "GeneratedArtProps"
	_art_props.z_index = -5
	add_child(_art_props)

	_add_prop(TORCH, Vector2(128, 96), 0.78)
	_add_prop(TORCH, Vector2(832, 96), 0.78)
	_add_prop(TORCH, Vector2(128, 444), 0.78)
	_add_prop(TORCH, Vector2(832, 444), 0.78)
	_add_prop(COLUMN, Vector2(92, 170), 0.78)
	_add_prop(COLUMN, Vector2(868, 170), 0.78)
	_add_prop(BROKEN_COLUMN, Vector2(92, 386), 0.78)
	_add_prop(BRAZIER, Vector2(868, 386), 0.72)

	var room_id := int(room_data.get("id", 0))
	if room_id % 2 == 0:
		_add_prop(BARREL, Vector2(220, 392), 0.82)
		_add_prop(CRATE, Vector2(748, 150), 0.82)
	else:
		_add_prop(CRATE, Vector2(220, 150), 0.82)
		_add_prop(BARREL, Vector2(748, 392), 0.82)

	var kind := StringName(room_data.get("kind", &"combat"))
	var marker := _marker_for_kind(kind)
	if marker != null:
		_add_prop(marker, Vector2(480, 270), 1.12, -6)

	if kind == &"treasure":
		_add_prop(TREASURE_CHEST, Vector2(480, 395), 1.0, -3)

func _add_prop(texture: Texture2D, at: Vector2, scale_factor: float, layer: int = -4) -> void:
	if texture == null or not is_instance_valid(_art_props):
		return
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = at
	sprite.scale = Vector2.ONE * scale_factor
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.z_index = layer
	_art_props.add_child(sprite)

func _marker_for_kind(kind: StringName) -> Texture2D:
	match kind:
		&"start":
			return START_MARKER
		&"treasure":
			return TREASURE_MARKER
		&"event":
			return EVENT_MARKER
		&"miniboss":
			return MINIBOSS_MARKER
		&"boss":
			return BOSS_MARKER
		_:
			return COMBAT_MARKER

func _tileset_for_kind(kind: StringName) -> Texture2D:
	match kind:
		&"event", &"treasure":
			return STONE_MOSS_TILESET
		&"miniboss", &"boss":
			return STONE_BLOOD_TILESET
		_:
			return STONE_TILESET

func _accent_for_kind(kind: StringName) -> Color:
	match kind:
		&"start":
			return Color(0.24, 0.82, 1.0)
		&"event":
			return Color(0.72, 0.38, 1.0)
		&"treasure":
			return Color(1.0, 0.70, 0.20)
		&"miniboss":
			return Color(1.0, 0.34, 0.12)
		&"boss":
			return Color(0.90, 0.22, 1.0)
		_:
			return Color(0.30, 0.58, 0.92)

func _draw() -> void:
	var kind := StringName(room_data.get("kind", &"combat"))
	var sheet := _tileset_for_kind(kind)
	var accent := _accent_for_kind(kind)
	var floor_region := Rect2(64, 32, 32, 32)
	var wall_region := Rect2(0, 96, 32, 32)

	draw_rect(Rect2(0, 0, 960, 540), Color(0.012, 0.014, 0.022), true)

	for y in range(32, 512, 64):
		for x in range(32, 928, 64):
			draw_texture_rect_region(sheet, Rect2(x, y, 64, 64), floor_region)

	for x in range(0, 960, 64):
		draw_texture_rect_region(STONE_TILESET, Rect2(x, 0, 64, 64), wall_region)
		draw_texture_rect_region(STONE_TILESET, Rect2(x, 476, 64, 64), wall_region)

	for y in range(64, 476, 64):
		draw_texture_rect_region(STONE_TILESET, Rect2(0, y, 64, 64), wall_region)
		draw_texture_rect_region(STONE_TILESET, Rect2(896, y, 64, 64), wall_region)

	draw_rect(Rect2(24, 24, 912, 492), Color(accent, 0.20), false, 2.0)
	draw_rect(Rect2(32, 32, 896, 476), Color(0.02, 0.025, 0.04, 0.12), true)
