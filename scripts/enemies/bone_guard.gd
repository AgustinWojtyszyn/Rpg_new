extends EnemyBase

@export_range(0.0, 1.0, 0.05) var front_damage_multiplier: float = 0.18
@export_range(1, 10, 1) var blocks_before_break: int = 3
@export_range(0.2, 5.0, 0.1) var shield_break_duration: float = 1.8

var _facing := Vector2.DOWN
var _blocks := 0
var _shield_break_left := 0.0

func _physics_process(delta: float) -> void:
	_tick_contact_cooldown(delta)
	_shield_break_left = maxf(0.0, _shield_break_left - delta)

	if not _has_valid_target():
		velocity = Vector2.ZERO
		return

	var to_target := target.global_position - global_position
	if to_target != Vector2.ZERO:
		_facing = to_target.normalized()

	var speed_scale := 1.22 if _shield_break_left > 0.0 else 0.82
	velocity = _facing * definition.move_speed * speed_scale
	move_and_slide()
	_damage_player_on_collision()
	_clamp_to_arena()
	queue_redraw()

func receive_projectile_hit(amount: float, source_position: Vector2) -> void:
	if _shield_break_left > 0.0:
		receive_hit(amount)
		return

	var incoming := (source_position - global_position).normalized()
	var hit_from_front := _facing.dot(incoming) > 0.30
	if not hit_from_front:
		receive_hit(amount)
		return

	health.apply_damage(amount * front_damage_multiplier)
	_blocks += 1
	if _blocks >= blocks_before_break:
		_blocks = 0
		_shield_break_left = shield_break_duration
	queue_redraw()

func _draw() -> void:
	var bone := definition.placeholder_color if definition != null else Color(0.88, 0.86, 0.74)
	draw_circle(Vector2.ZERO, 12.0, bone)
	draw_circle(_facing * 8.0, 4.0, Color(0.20, 0.10, 0.10))
	if _shield_break_left <= 0.0:
		var shield_center := _facing * 18.0
		var tangent := _facing.orthogonal()
		draw_polygon(
			PackedVector2Array([
				shield_center + tangent * 12.0 - _facing * 8.0,
				shield_center + tangent * 11.0 + _facing * 8.0,
				shield_center - tangent * 11.0 + _facing * 8.0,
				shield_center - tangent * 12.0 - _facing * 8.0,
			]),
			PackedColorArray([Color(0.50, 0.56, 0.64)])
		)
	else:
		draw_arc(Vector2.ZERO, 19.0, 0.0, TAU, 24, Color(1.0, 0.72, 0.25), 3.0)
