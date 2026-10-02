extends EnemyBase

@export_range(20.0, 400.0, 1.0) var grab_range: float = 175.0
@export_range(0.1, 5.0, 0.05) var grab_duration: float = 1.15
@export_range(0.1, 10.0, 0.1) var grab_cooldown: float = 3.8
@export_range(1.0, 100.0, 1.0) var pull_impulse: float = 22.0
@export_range(0.0, 100.0, 1.0) var bite_damage: float = 10.0

var _grab_time_left := 0.0
var _grab_cooldown_left := 0.8

func _physics_process(delta: float) -> void:
	_tick_contact_cooldown(delta)
	_grab_cooldown_left = maxf(0.0, _grab_cooldown_left - delta)
	velocity = Vector2.ZERO

	if not _has_valid_target():
		_end_grab()
		return

	var distance := global_position.distance_to(target.global_position)
	if _grab_time_left > 0.0:
		_grab_time_left = maxf(0.0, _grab_time_left - delta)
		if target.has_method("is_dashing") and bool(target.call("is_dashing")):
			_end_grab()
		elif distance > grab_range * 1.25:
			_end_grab()
		else:
			if target.has_method("apply_pull"):
				target.call("apply_pull", global_position, pull_impulse)
			if _grab_time_left <= 0.0:
				if distance < 48.0 and target.has_method("receive_hit"):
					target.call("receive_hit", bite_damage)
				_end_grab()
	elif _grab_cooldown_left <= 0.0 and distance <= grab_range:
		_grab_time_left = grab_duration

	queue_redraw()

func _end_grab() -> void:
	if _grab_time_left > 0.0:
		_grab_time_left = 0.0
	_grab_cooldown_left = grab_cooldown

func _draw() -> void:
	var color := definition.placeholder_color if definition != null else Color(0.33, 0.76, 0.22)
	for angle_index in range(6):
		var angle := TAU * float(angle_index) / 6.0
		draw_line(Vector2.ZERO, Vector2.from_angle(angle) * 22.0, color.darkened(0.25), 5.0)
	draw_circle(Vector2.ZERO, 16.0, color)
	draw_circle(Vector2.ZERO, 7.0, Color(0.25, 0.05, 0.12))
	if _grab_time_left > 0.0 and is_instance_valid(target):
		draw_line(Vector2.ZERO, to_local(target.global_position), Color(0.60, 1.0, 0.35), 4.0)
