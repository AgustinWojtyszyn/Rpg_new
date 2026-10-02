class_name BreakableSetPiece
extends StaticBody2D

signal armed
signal broken

var is_armed: bool = false
var is_broken: bool = false

func _ready() -> void:
	queue_redraw()

func arm() -> void:
	if is_broken or is_armed:
		return
	is_armed = true
	armed.emit()
	queue_redraw()

func try_break(_source: Node) -> bool:
	if is_broken or not is_armed:
		return false
	is_broken = true
	$CollisionShape2D.set_deferred("disabled", true)
	broken.emit()
	queue_redraw()
	return true

func _draw() -> void:
	if is_broken:
		draw_rect(Rect2(-12, -45, 24, 38), Color(0.32, 0.26, 0.20), true)
		draw_rect(Rect2(-20, 15, 28, 24), Color(0.26, 0.22, 0.18), true)
		return

	var color := Color(0.92, 0.60, 0.18) if is_armed else Color(0.36, 0.40, 0.48)
	draw_rect(Rect2(-12, -45, 24, 90), color, true)
	draw_rect(Rect2(-16, -49, 32, 98), color.darkened(0.35), false, 3.0)
