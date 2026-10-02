class_name ChoiceRoom
extends RoomBase

signal option_chosen(option: Dictionary)

const CHOICE_PEDESTAL_SCENE := preload("res://scenes/rewards/choice_pedestal.tscn")

var heading: String = ""
var blurb: String = ""
var options: Array[Dictionary] = []
var _pedestals: Array[ChoicePedestal] = []
var _resolved := false
var _selected_title := ""

func setup(
	data: Dictionary,
	run_player: PlayerCharacter,
	new_heading: String,
	new_blurb: String,
	new_options: Array[Dictionary],
	already_cleared: bool
) -> void:
	heading = new_heading
	blurb = new_blurb
	options = new_options
	_resolved = already_cleared
	setup_base(data, run_player, already_cleared)

	if not already_cleared:
		_spawn_choices()
		if _pedestals.is_empty():
			mark_cleared()
			_resolved = true

	queue_redraw()

func _spawn_choices() -> void:
	var positions := _positions_for_count(options.size())
	for index in range(mini(options.size(), positions.size())):
		var pedestal := CHOICE_PEDESTAL_SCENE.instantiate() as ChoicePedestal
		pedestal.position = positions[index]
		pedestal.configure(options[index])
		pedestal.chosen.connect(_on_choice_selected)
		add_child(pedestal)
		_pedestals.append(pedestal)

func _positions_for_count(count: int) -> Array[Vector2]:
	match count:
		1:
			return [Vector2(480, 300)]
		2:
			return [Vector2(350, 300), Vector2(610, 300)]
		_:
			return [Vector2(245, 300), Vector2(480, 300), Vector2(715, 300)]

func _on_choice_selected(option: Dictionary) -> void:
	if _resolved:
		return
	_resolved = true
	_selected_title = String(option.get("title", "Elección"))
	for pedestal in _pedestals:
		pedestal.set_enabled(false)
	option_chosen.emit(option)
	mark_cleared()
	queue_redraw()

func _draw() -> void:
	super._draw()
	var font := ThemeDB.fallback_font
	var title := heading if not heading.is_empty() else String(room_data.get("kind", &"choice")).to_upper()
	draw_string(font, Vector2(280, 112), title, HORIZONTAL_ALIGNMENT_CENTER, 400, 24, Color(0.96, 0.92, 1.0))
	draw_multiline_string(font, Vector2(230, 140), blurb, HORIZONTAL_ALIGNMENT_CENTER, 500, 15, 40, Color(0.76, 0.82, 0.92))
	if _resolved and not _selected_title.is_empty():
		draw_string(font, Vector2(310, 430), "Elegiste: %s" % _selected_title, HORIZONTAL_ALIGNMENT_CENTER, 340, 16, Color(0.62, 1.0, 0.76))
