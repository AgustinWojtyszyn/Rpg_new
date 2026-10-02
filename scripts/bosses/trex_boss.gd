extends BossBase

enum State {
	STALK,
	WINDUP,
	CHARGE,
	RECOVER,
	STUNNED,
}

@export_range(10.0, 500.0, 1.0) var stalk_speed: float = 92.0
@export_range(100.0, 1200.0, 1.0) var charge_speed: float = 430.0
@export_range(0.1, 3.0, 0.05) var windup_time: float = 0.48
@export_range(0.1, 3.0, 0.05) var charge_time: float = 0.78
@export_range(0.1, 3.0, 0.05) var recovery_time: float = 0.55
@export_range(0.1, 5.0, 0.05) var stun_time: float = 1.35
@export_range(0.1, 100.0, 1.0) var charge_damage: float = 24.0

var state: State = State.STALK
var _state_time_left := 0.0
var _charge_cooldown_left := 1.2
var _charge_direction := Vector2.DOWN
var _charge_point := Vector2.ZERO
var _charge_setpiece: BreakableSetPiece
var _special_charge_pending := false
var _hit_player_this_charge := false
var _facing := Vector2.DOWN

func _ready() -> void:
	super()
	phase_changed.connect(_on_phase_changed)
	queue_redraw()

func _physics_process(delta: float) -> void:
	_charge_cooldown_left = maxf(0.0, _charge_cooldown_left - delta)
	_state_time_left = maxf(0.0, _state_time_left - delta)

	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		return

	match state:
		State.STALK:
			_tick_stalk()
		State.WINDUP:
			velocity = Vector2.ZERO
			if _state_time_left <= 0.0:
				_charge_direction = (_charge_point - global_position).normalized()
				if _charge_direction == Vector2.ZERO:
					_charge_direction = _facing
				_facing = _charge_direction
				_enter_state(State.CHARGE, charge_time)
		State.CHARGE:
			velocity = _charge_direction * charge_speed
			move_and_slide()
			if _handle_charge_collisions():
				return
			_clamp_to_arena()
			if _state_time_left <= 0.0:
				_enter_state(State.RECOVER, recovery_time)
		State.RECOVER:
			velocity = Vector2.ZERO
			if _state_time_left <= 0.0:
				_charge_cooldown_left = _normal_charge_cooldown()
				_enter_state(State.STALK, 0.0)
		State.STUNNED:
			velocity = Vector2.ZERO
			if _state_time_left <= 0.0:
				_charge_cooldown_left = 0.8
				_enter_state(State.STALK, 0.0)

	queue_redraw()

func _tick_stalk() -> void:
	var to_target := target.global_position - global_position
	if to_target != Vector2.ZERO:
		_facing = to_target.normalized()

	var special_target := _find_armed_setpiece() if _special_charge_pending else null
	if special_target != null and _charge_cooldown_left <= 0.0:
		_begin_charge(special_target)
		return

	if _charge_cooldown_left <= 0.0 and to_target.length() <= 300.0:
		_begin_charge(null)
		return

	var speed_multiplier := 1.0 + float(phase_model.current_phase) * 0.13
	velocity = to_target.normalized() * stalk_speed * speed_multiplier
	move_and_slide()
	_damage_player_from_contacts(10.0)
	_clamp_to_arena()

func _begin_charge(setpiece: BreakableSetPiece) -> void:
	_charge_setpiece = setpiece
	_charge_point = setpiece.global_position if setpiece != null else target.global_position
	_hit_player_this_charge = false
	_enter_state(State.WINDUP, windup_time)

func _handle_charge_collisions() -> bool:
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		var collider := collision.get_collider()

		if _charge_setpiece != null and collider == _charge_setpiece:
			if _charge_setpiece.try_break(self):
				_special_charge_pending = false
				_charge_setpiece = null
				_enter_state(State.STUNNED, stun_time)
				return true

		if not _hit_player_this_charge and collider is PlayerCharacter:
			(collider as PlayerCharacter).receive_hit(charge_damage)
			_hit_player_this_charge = true

	return false

func _damage_player_from_contacts(amount: float) -> void:
	for index in range(get_slide_collision_count()):
		var collider := get_slide_collision(index).get_collider()
		if collider is PlayerCharacter:
			(collider as PlayerCharacter).receive_hit(amount)
			return

func _find_armed_setpiece() -> BreakableSetPiece:
	var closest: BreakableSetPiece
	var closest_distance := INF
	for node in get_tree().get_nodes_in_group("charge_breakable"):
		if node is not BreakableSetPiece:
			continue
		var setpiece := node as BreakableSetPiece
		if not setpiece.is_armed or setpiece.is_broken:
			continue
		var distance := global_position.distance_squared_to(setpiece.global_position)
		if distance < closest_distance:
			closest = setpiece
			closest_distance = distance
	return closest

func _on_phase_changed(_phase: int) -> void:
	_special_charge_pending = true
	_charge_cooldown_left = minf(_charge_cooldown_left, 0.6)

func _normal_charge_cooldown() -> float:
	return maxf(1.25, 2.7 - float(phase_model.current_phase) * 0.45)

func _enter_state(new_state: State, duration: float) -> void:
	state = new_state
	_state_time_left = duration
	queue_redraw()

func _clamp_to_arena() -> void:
	global_position.x = clampf(global_position.x, 42.0, 918.0)
	global_position.y = clampf(global_position.y, 48.0, 492.0)

func _draw() -> void:
	var body_color := Color(0.30, 0.72, 0.28)
	if state == State.STUNNED:
		body_color = Color(0.58, 0.62, 0.68)
	elif phase_model != null and phase_model.current_phase >= 2:
		body_color = Color(0.45, 0.82, 0.25)

	draw_circle(Vector2.ZERO, 30.0, body_color)
	draw_circle(_facing * 24.0, 19.0, body_color.lightened(0.08))
	draw_polygon(
		PackedVector2Array([
			-_facing * 18.0 + _facing.orthogonal() * 8.0,
			-_facing * 52.0,
			-_facing * 18.0 - _facing.orthogonal() * 8.0,
		]),
		PackedColorArray([body_color.darkened(0.20)])
	)

	if state == State.WINDUP:
		var local_target := to_local(_charge_point)
		draw_line(Vector2.ZERO, local_target, Color(1.0, 0.18, 0.12, 0.78), 5.0)
		draw_arc(Vector2.ZERO, 38.0, 0.0, TAU, 40, Color(1.0, 0.72, 0.12), 4.0)
	elif state == State.CHARGE:
		draw_arc(Vector2.ZERO, 40.0, 0.0, TAU, 40, Color(1.0, 0.22, 0.12), 4.0)
