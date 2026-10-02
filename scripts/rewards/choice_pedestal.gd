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

	draw_rect(Rect2(-52, -18, 104, 36), Color(0.08, 0.10, 0.14, 0.92), true)
	draw_rect(Rect2(-52, -18, 104, 36), accent, false, 3.0)
	draw_circle(Vector2(0, -28), 16.0, accent)

	var font := ThemeDB.fallback_font
	var title := String(option.get("title", "Elección"))
	var description := String(option.get("description", ""))
	draw_string(font, Vector2(-86, 42), title, HORIZONTAL_ALIGNMENT_CENTER, 172, 15, Color.WHITE)
	draw_multiline_string(font, Vector2(-100, 64), description, HORIZONTAL_ALIGNMENT_CENTER, 200, 13, 32, Color(0.82, 0.86, 0.92))
	if _player != null and _enabled:
		draw_string(font, Vector2(-26, -54), "USE", HORIZONTAL_ALIGNMENT_CENTER, 52, 14, accent)
