extends BossBase

signal dimension_cast_requested(theme: StringName, budget: int)

@export var projectile_scene: PackedScene
@export_range(20.0, 500.0, 1.0) var move_speed: float = 86.0
@export_range(0.1, 10.0, 0.1) var fire_interval: float = 1.15
@export_range(0.1, 5.0, 0.05) var cast_windup: float = 0.85
@export_range(50.0, 500.0, 1.0) var preferred_range: float = 220.0

const DIMENSION_THEMES: Array[StringName] = [
	&"prehistoric",
	&"alien",
	&"overgrowth",
]

var _fire_left := 0.6
var _dimension_pending := false
var _casting := false
var _waiting_for_return := false
var _cast_left := 0.0
var _dimension_index := 0
var _strafe_sign := 1.0
var _visual_angle := 0.0

func _ready() -> void:
	super()
	phase_changed.connect(_on_phase_changed)
	queue_redraw()

func _physics_process(delta: float) -> void:
	_fire_left = maxf(0.0, _fire_left - delta)
	_visual_angle = fmod(_visual_angle + delta * 1.4, TAU)

	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		return

	if _waiting_for_return:
		velocity = Vector2.ZERO
		return

	if _casting:
		velocity = Vector2.ZERO
		_cast_left = maxf(0.0, _cast_left - delta)
		if _cast_left <= 0.0:
			_casting = false
			_waiting_for_return = true
			var theme := DIMENSION_THEMES[_dimension_index % DIMENSION_THEMES.size()]
			var budget := 7 + phase_model.current_phase * 2
			_dimension_index += 1
			dimension_cast_requested.emit(theme, budget)
		queue_redraw()
		return

	if _dimension_pending:
		_dimension_pending = false
		_casting = true
		_cast_left = cast_windup
		queue_redraw()
		return

	var to_target := target.global_position - global_position
	var distance := to_target.length()
	var radial := Vector2.ZERO
	if distance > preferred_range + 35.0:
		radial = to_target.normalized()
	elif distance < preferred_range - 35.0:
		radial = -to_target.normalized()

	var tangent := Vector2(-to_target.y, to_target.x).normalized() * _strafe_sign
	velocity = (radial + tangent * 0.65).normalized() * move_speed * (1.0 + phase_model.current_phase * 0.08)
	move_and_slide()
	_clamp_to_arena()

	if _fire_left <= 0.0 and distance < 420.0:
		_fire(to_target.normalized())
		_fire_left = maxf(0.48, fire_interval - phase_model.current_phase * 0.12)

	queue_redraw()

func on_dimension_returned() -> void:
	_waiting_for_return = false
	_fire_left = 0.45
	_strafe_sign *= -1.0
	queue_redraw()

func _on_phase_changed(_phase: int) -> void:
	if not _waiting_for_return and not _casting:
		_dimension_pending = true

func _fire(direction: Vector2) -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate() as Projectile
	if projectile == null:
		return
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.launch(direction)

func _clamp_to_arena() -> void:
	global_position.x = clampf(global_position.x, 70.0, 890.0)
	global_position.y = clampf(global_position.y, 80.0, 460.0)

func _draw() -> void:
	var core := Color(0.16, 0.04, 0.25)
	var glow := Color(0.82, 0.28, 1.0)
	if _casting:
		glow = Color(0.25, 0.95, 1.0)

	draw_circle(Vector2.ZERO, 27.0, core)
	draw_arc(Vector2.ZERO, 34.0, 0.0, TAU, 40, glow, 4.0)
	for index in range(3):
		var angle := _visual_angle + TAU * float(index) / 3.0
		var point := Vector2.from_angle(angle) * 43.0
		draw_circle(point, 7.0, glow.lightened(0.12))
		draw_line(Vector2.ZERO, point, Color(glow, 0.35), 2.0)

	if _casting:
		draw_arc(Vector2.ZERO, 52.0, 0.0, TAU, 48, Color(0.35, 1.0, 0.95), 5.0)
