extends EnemyBase

@export var projectile_scene: PackedScene
@export_range(0.2, 10.0, 0.1) var fire_interval: float = 1.4
@export_range(0.5, 20.0, 0.1) var teleport_cooldown: float = 4.5
@export_range(20.0, 400.0, 1.0) var teleport_distance: float = 130.0

var _fire_left := 0.8
var _teleport_left := 2.5
var _teleport_side := 1.0

func _physics_process(delta: float) -> void:
	_tick_contact_cooldown(delta)
	_fire_left = maxf(0.0, _fire_left - delta)
	_teleport_left = maxf(0.0, _teleport_left - delta)

	if not _has_valid_target():
		velocity = Vector2.ZERO
		return

	var to_target := target.global_position - global_position
	var distance := to_target.length()
	if distance > definition.preferred_range + 30.0:
		velocity = to_target.normalized() * definition.move_speed
	elif distance < definition.preferred_range - 45.0:
		velocity = -to_target.normalized() * definition.move_speed
	else:
		velocity = Vector2.ZERO

	if distance < 125.0 and _teleport_left <= 0.0:
		var perpendicular := Vector2(-to_target.y, to_target.x).normalized()
		global_position = target.global_position + perpendicular * teleport_distance * _teleport_side
		_teleport_side *= -1.0
		_teleport_left = teleport_cooldown
		_clamp_to_arena()

	if _fire_left <= 0.0 and distance < 360.0:
		_fire(to_target.normalized())
		_fire_left = fire_interval

	move_and_slide()
	_damage_player_on_collision()
	_clamp_to_arena()

func _fire(direction: Vector2) -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate() as Projectile
	if projectile == null:
		return
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.launch(direction)

func _draw() -> void:
	var color := definition.placeholder_color if definition != null else Color(0.70, 0.34, 1.0)
	draw_circle(Vector2.ZERO, 15.0, color)
	draw_circle(Vector2.ZERO, 8.0, Color(0.12, 0.02, 0.24))
	draw_circle(Vector2.ZERO, 3.0, Color(0.30, 0.95, 1.0))
	draw_arc(Vector2.ZERO, 21.0, 0.0, TAU, 32, color.lightened(0.2), 2.0)
