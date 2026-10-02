class_name ChoicePedestal
extends Area2D

signal chosen(option: Dictionary)

var option: Dictionary = {}
var _player: PlayerCharacter
var _enabled := true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	queue_redraw()

func configure(new_option: Dictionary) -> void:
	option = new_option
	queue_redraw()

func set_enabled(value: bool) -> void:
	_enabled = value
	if not _enabled:
		_disconnect_player()
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if not _enabled or body is not PlayerCharacter:
		return
	_player = body as PlayerCharacter
	if not _player.interact_requested.is_connected(_choose):
		_player.interact_requested.connect(_choose)
	queue_redraw()

func _on_body_exited(body: Node) -> void:
	if body != _player:
		return
	_disconnect_player()
	queue_redraw()

func _choose() -> void:
	if not _enabled or option.is_empty():
		return
	chosen.emit(option)

func _disconnect_player() -> void:
	if _player != null and is_instance_valid(_player) and _player.interact_requested.is_connected(_choose):
		_player.interact_requested.disconnect(_choose)
	_player = null

func _draw() -> void:
	var kind := StringName(option.get("kind", &"effect"))
	var accent := Color(0.55, 0.90, 1.0)
	match kind:
		&"weapon":
			accent = Color(1.0, 0.55, 0.22)
		&"modifier":
			accent = Color(0.70, 0.40, 1.0)
		&"effect":
			accent = Color(0.38, 1.0, 0.62)

	if not _enabled:
		accent = Color(0.30, 0.32, 0.36)

	draw_ellipse_shadow()
	draw_rect(Rect2(-44, -4, 88, 22), Color(0.07, 0.08, 0.12, 0.96), true)
	draw_rect(Rect2(-36, -16, 72, 16), accent.darkened(0.55), true)
	draw_rect(Rect2(-28, -28, 56, 14), accent.darkened(0.35), true)
	draw_circle(Vector2(0, -49), 20.0, Color(accent, 0.16))
	draw_arc(Vector2(0, -49), 20.0, 0.0, TAU, 28, accent, 3.0)
	draw_circle(Vector2(0, -49), 8.0, accent.lightened(0.18))

	var font := ThemeDB.fallback_font
	var title := String(option.get("title", "Elección"))
	var description := String(option.get("description", ""))
	draw_string(font, Vector2(-92, 43), title, HORIZONTAL_ALIGNMENT_CENTER, 184, 15, Color.WHITE)
	draw_multiline_string(font, Vector2(-104, 65), description, HORIZONTAL_ALIGNMENT_CENTER, 208, 13, 34, Color(0.82, 0.86, 0.92))
	if _player != null and _enabled:
		draw_string(font, Vector2(-30, -80), "USE", HORIZONTAL_ALIGNMENT_CENTER, 60, 14, accent)

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2(0, 48), 36.0, Color(0.0, 0.0, 0.0, 0.24))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
