class_name LeverTrigger
extends Area2D

@export var target_path: NodePath

var _player: PlayerCharacter
var _activated := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body is not PlayerCharacter:
		return
	_player = body as PlayerCharacter
	if not _player.interact_requested.is_connected(_activate):
		_player.interact_requested.connect(_activate)
	queue_redraw()

func _on_body_exited(body: Node) -> void:
	if body != _player:
		return
	if _player != null and _player.interact_requested.is_connected(_activate):
		_player.interact_requested.disconnect(_activate)
	_player = null
	queue_redraw()

func _activate() -> void:
	if _activated:
		return
	var setpiece := get_node_or_null(target_path)
	if setpiece == null or not setpiece.has_method("arm"):
		return
	setpiece.call("arm")
	_activated = true
	queue_redraw()

func _draw() -> void:
	var color := Color(0.25, 0.95, 0.42) if _activated else Color(1.0, 0.82, 0.20)
	draw_rect(Rect2(-9, -14, 18, 28), color, true)
	draw_line(Vector2(0, -8), Vector2(10, -22), Color(0.9, 0.9, 0.9), 4.0)
	if _player != null and not _activated:
		draw_arc(Vector2.ZERO, 24.0, 0.0, TAU, 24, Color.WHITE, 2.0)
