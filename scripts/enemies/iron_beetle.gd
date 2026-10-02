extends EnemyBase

enum State {
	STALK,
	WINDUP,
	ROLL,
	RECOVER,
}

@export_range(0.2, 5.0, 0.1) var roll_cooldown: float = 2.9
@export_range(0.1, 2.0, 0.05) var windup_duration: float = 0.42
@export_range(0.1, 2.0, 0.05) var roll_duration: float = 0.68
@export_range(0.1, 3.0, 0.05) var recovery_duration: float = 1.1
@export_range(1.0, 6.0, 0.1) var roll_speed_multiplier: float = 3.0
@export_range(0.0, 1.0, 0.05) var rolling_damage_multiplier: float = 0.30
@export_range(1.0, 4.0, 0.05) var recovery_damage_multiplier: float = 1.65

var state: State = State.STALK
var _state_left := 0.0
var _cooldown_left := 1.4
var _roll_direction := Vector2.DOWN

func _physics_process(delta: float) -> void:
	_tick_contact_cooldown(delta)
	_state_left = maxf(0.0, _state_left - delta)
	_cooldown_left = maxf(0.0, _cooldown_left - delta)

	if not _has_valid_target():
		velocity = Vector2.ZERO
		return

	match state:
		State.STALK:
			var to_target := target.global_position - global_position
			velocity = to_target.normalized() * definition.move_speed
			if _cooldown_left <= 0.0 and to_target.length() < 250.0:
				_roll_direction = to_target.normalized()
				state = State.WINDUP
				_state_left = windup_duration
		State.WINDUP:
			velocity = Vector2.ZERO
			if _state_left <= 0.0:
				state = State.ROLL
				_state_left = roll_duration
		State.ROLL:
			velocity = _roll_direction * definition.move_speed * roll_speed_multiplier
			if _state_left <= 0.0:
				state = State.RECOVER
				_state_left = recovery_duration
		State.RECOVER:
			velocity = Vector2.ZERO
			if _state_left <= 0.0:
				state = State.STALK
				_cooldown_left = roll_cooldown

	move_and_slide()
	_damage_player_on_collision()
	_clamp_to_arena()
	queue_redraw()

func receive_projectile_hit(amount: float, _source_position: Vector2) -> void:
	match state:
		State.ROLL:
			receive_hit(amount * rolling_damage_multiplier)
		State.RECOVER:
			receive_hit(amount * recovery_damage_multiplier)
		_:
			receive_hit(amount)

func _draw() -> void:
	var shell := definition.placeholder_color if definition != null else Color(0.95, 0.50, 0.18)
	if state == State.RECOVER:
		shell = shell.lightened(0.35)
	draw_circle(Vector2.ZERO, 17.0, shell)
	draw_arc(Vector2.ZERO, 13.0, 0.0, TAU, 24, shell.darkened(0.42), 4.0)
	draw_line(Vector2(-9, -13), Vector2(-15, -22), shell.darkened(0.2), 3.0)
	draw_line(Vector2(9, -13), Vector2(15, -22), shell.darkened(0.2), 3.0)
	if state == State.WINDUP:
		draw_arc(Vector2.ZERO, 23.0, 0.0, TAU, 28, Color(1.0, 0.82, 0.20), 3.0)
	elif state == State.ROLL:
		draw_arc(Vector2.ZERO, 24.0, 0.0, TAU, 28, Color(1.0, 0.30, 0.10), 4.0)
