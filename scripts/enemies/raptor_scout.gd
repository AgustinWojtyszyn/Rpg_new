extends EnemyBase

enum State {
	FLANK,
	WINDUP,
	LUNGE,
}

@export_range(0.1, 10.0, 0.1) var lunge_cooldown: float = 2.0
@export_range(0.05, 1.0, 0.01) var lunge_windup: float = 0.24
@export_range(0.05, 1.0, 0.01) var lunge_duration: float = 0.28
@export_range(1.0, 5.0, 0.1) var lunge_speed_multiplier: float = 2.5
@export_range(20.0, 300.0, 1.0) var flank_distance: float = 90.0

var state: State = State.FLANK
var _lunge_cooldown_left := 0.8
var _state_time_left := 0.0
var _lunge_direction := Vector2.RIGHT
var _flank_sign := 1.0

func _ready() -> void:
	super()
	_flank_sign = -1.0 if global_position.x < 480.0 else 1.0

func _physics_process(delta: float) -> void:
	_tick_contact_cooldown(delta)
	_lunge_cooldown_left = maxf(0.0, _lunge_cooldown_left - delta)
	_state_time_left = maxf(0.0, _state_time_left - delta)

	if not _has_valid_target():
		velocity = Vector2.ZERO
		return

	var to_target := target.global_position - global_position

	match state:
		State.FLANK:
			if _lunge_cooldown_left <= 0.0 and to_target.length() < 210.0:
				_lunge_direction = to_target.normalized()
				state = State.WINDUP
				_state_time_left = lunge_windup
				velocity = Vector2.ZERO
			else:
				var perpendicular := Vector2(-to_target.y, to_target.x).normalized()
				var flank_point := target.global_position + perpendicular * flank_distance * _flank_sign
				velocity = (flank_point - global_position).normalized() * definition.move_speed
		State.WINDUP:
			velocity = Vector2.ZERO
			if _state_time_left <= 0.0:
				state = State.LUNGE
				_state_time_left = lunge_duration
		State.LUNGE:
			velocity = _lunge_direction * definition.move_speed * lunge_speed_multiplier
			if _state_time_left <= 0.0:
				state = State.FLANK
				_lunge_cooldown_left = lunge_cooldown
				_flank_sign *= -1.0

	move_and_slide()
	_damage_player_on_collision()
	_clamp_to_arena()
	queue_redraw()

func _draw() -> void:
	var color := definition.placeholder_color if definition != null else Color(0.36, 0.88, 0.42)
	draw_circle(Vector2.ZERO, 13.0, color)
	draw_polygon(
		PackedVector2Array([Vector2(-8, -7), Vector2(-23, -12), Vector2(-12, 1)]),
		PackedColorArray([color.darkened(0.2)])
	)
	draw_polygon(
		PackedVector2Array([Vector2(6, -10), Vector2(15, -5), Vector2(7, -2)]),
		PackedColorArray([Color(1.0, 0.94, 0.65)])
	)

	if state == State.WINDUP:
		draw_line(Vector2.ZERO, _lunge_direction * 80.0, Color(1.0, 0.78, 0.18, 0.82), 3.0)
		draw_arc(Vector2.ZERO, 20.0, 0.0, TAU, 24, Color(1.0, 0.78, 0.18), 2.0)
	elif state == State.LUNGE:
		draw_arc(Vector2.ZERO, 20.0, 0.0, TAU, 24, Color(1.0, 0.35, 0.15), 3.0)
