extends TouchScreenButton

@export var label_text: String = "A"
@export var base_color := Color(0.12, 0.16, 0.24, 0.78)
@export var accent_color := Color(0.40, 0.82, 1.0, 0.95)
@export_range(12.0, 64.0, 1.0) var radius: float = 34.0

func _ready() -> void:
	pressed.connect(queue_redraw)
	released.connect(queue_redraw)
	queue_redraw()

func _draw() -> void:
	var fill := accent_color if is_pressed() else base_color
	draw_circle(Vector2.ZERO, radius, fill)
	draw_arc(Vector2.ZERO, radius - 2.0, 0.0, TAU, 32, accent_color, 3.0)
	var font := ThemeDB.fallback_font
	var font_size := maxi(16, int(radius * 0.58))
	var text_size := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	draw_string(
		font,
		Vector2(-text_size.x * 0.5, text_size.y * 0.32),
		label_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		Color.WHITE
	)
