class_name RoomDoor
extends Area2D

signal traversed(destination_room_id: int, exit_slot: StringName)

const DOOR_TEXTURE := preload("res://assets/generated/props/structures/stone_dungeon_door.png")

var destination_room_id: int = -1
var slot: StringName = &""
var active: bool = false
var _art_sprite: Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_build_generated_art()
	queue_redraw()

func configure(new_slot: StringName, destination: int, enabled: bool) -> void:
	slot = new_slot
	destination_room_id = destination
	set_active(enabled)

func set_active(enabled: bool) -> void:
	active = enabled
	if is_instance_valid(_art_sprite):
		_art_sprite.modulate = Color.WHITE if active else Color(0.72, 0.40, 0.38, 0.86)
	queue_redraw()

func _build_generated_art() -> void:
	if is_instance_valid(_art_sprite):
		return
	_art_sprite = Sprite2D.new()
	_art_sprite.texture = DOOR_TEXTURE
	_art_sprite.scale = Vector2.ONE * 0.72
	_art_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_art_sprite.z_index = 4
	if slot == &"east" or slot == &"west":
		_art_sprite.rotation = PI * 0.5
	add_child(_art_sprite)
	set_active(active)

func _on_body_entered(body: Node) -> void:
	if not active or destination_room_id < 0:
		return
	if body is PlayerCharacter:
		traversed.emit(destination_room_id, slot)

func _draw() -> void:
	var color := Color(0.28, 0.92, 1.0) if active else Color(0.95, 0.25, 0.18)
	var radius := 23.0 if active else 18.0
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 28, Color(color, 0.46), 2.0)
