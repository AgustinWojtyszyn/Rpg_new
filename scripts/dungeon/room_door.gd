class_name RoomDoor
extends Area2D

signal traversed(destination_room_id: int, exit_slot: StringName)

var destination_room_id: int = -1
var slot: StringName = &""
var active: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func configure(new_slot: StringName, destination: int, enabled: bool) -> void:
	slot = new_slot
	destination_room_id = destination
	set_active(enabled)

func set_active(enabled: bool) -> void:
	active = enabled
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if not active or destination_room_id < 0:
		return
	if body is PlayerCharacter:
		traversed.emit(destination_room_id, slot)

func _draw() -> void:
	var color := Color(0.20, 0.88, 1.0) if active else Color(0.78, 0.22, 0.18)
	var half := Vector2(30, 12)
	if slot == &"east" or slot == &"west":
		half = Vector2(12, 30)
	draw_rect(Rect2(-half, half * 2.0), Color(color, 0.22), true)
	draw_rect(Rect2(-half, half * 2.0), color, false, 3.0)
