class_name PlayerCharacter
extends CharacterBody2D

signal interact_requested
signal defeated

@export_range(10.0, 1000.0, 1.0) var move_speed: float = 220.0
@export_range(10.0, 1500.0, 1.0) var dash_speed: float = 560.0
@export_range(0.05, 1.0, 0.01) var dash_duration: float = 0.14
@export_range(0.1, 5.0, 0.05) var dash_cooldown: float = 0.85
@export var aim_assist_enabled: bool = true
@export_range(50.0, 1000.0, 10.0) var aim_assist_range: float = 460.0
@export var projectile_scene: PackedScene

@onready var health: HealthComponent = $Health

var last_aim_direction := Vector2.RIGHT
var _external_velocity := Vector2.ZERO
var _dash_direction := Vector2.RIGHT
var _dash_time_left := 0.0
var _dash_cooldown_left := 0.0
var _defeated := false

func _ready() -> void:
	health.died.connect(_on_died)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if _defeated:
		velocity = Vector2.ZERO
		return

	_dash_cooldown_left = maxf(0.0, _dash_cooldown_left - delta)
	_dash_time_left = maxf(0.0, _dash_time_left - delta)

	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector != Vector2.ZERO:
		last_aim_direction = input_vector.normalized()

	if Input.is_action_just_pressed("dash") and _dash_cooldown_left <= 0.0:
		_dash_direction = input_vector.normalized() if input_vector != Vector2.ZERO else last_aim_direction
		_dash_time_left = dash_duration
		_dash_cooldown_left = dash_cooldown

	if Input.is_action_just_pressed("interact"):
		interact_requested.emit()

	if _dash_time_left > 0.0:
		velocity = _dash_direction * dash_speed + _external_velocity * 0.25
	else:
		velocity = input_vector * move_speed + _external_velocity

	move_and_slide()
	_external_velocity = _external_velocity.move_toward(Vector2.ZERO, 900.0 * delta)

	if Input.is_action_just_pressed("attack"):
		_fire()

	global_position.x = clampf(global_position.x, 20.0, 940.0)
	global_position.y = clampf(global_position.y, 20.0, 520.0)
	queue_redraw()

func apply_pull(source_position: Vector2, strength: float) -> void:
	if _defeated:
		return
	var pull_direction := (source_position - global_position).normalized()
	_external_velocity += pull_direction * maxf(0.0, strength)
	if _external_velocity.length() > 260.0:
		_external_velocity = _external_velocity.normalized() * 260.0

func is_dashing() -> bool:
	return not _defeated and _dash_time_left > 0.0

func is_defeated() -> bool:
	return _defeated

func revive(at_position: Vector2) -> void:
	global_position = at_position
	_external_velocity = Vector2.ZERO
	_dash_time_left = 0.0
	_dash_cooldown_left = 0.0
	_defeated = false
	health.reset()
	set_physics_process(true)
	queue_redraw()

func _fire() -> void:
	if _defeated or projectile_scene == null:
		return

	var attack_direction := _get_attack_direction()
	last_aim_direction = attack_direction

	var projectile := projectile_scene.instantiate() as Projectile
	if projectile == null:
		return
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + attack_direction * 20.0
	projectile.launch(attack_direction)

func _get_attack_direction() -> Vector2:
	if not aim_assist_enabled:
		return last_aim_direction

	var closest_distance_sq := aim_assist_range * aim_assist_range
	var closest_target: Node2D

	for candidate in get_tree().get_nodes_in_group("aim_targets"):
		if candidate is not Node2D:
			continue
		var target_node := candidate as Node2D
		if not is_instance_valid(target_node) or target_node.is_queued_for_deletion():
			continue
		if target_node is CanvasItem and not (target_node as CanvasItem).is_visible_in_tree():
			continue

		var distance_sq := global_position.distance_squared_to(target_node.global_position)
		if distance_sq < closest_distance_sq:
			closest_distance_sq = distance_sq
			closest_target = target_node

	if closest_target != null:
		var assisted := (closest_target.global_position - global_position).normalized()
		if assisted != Vector2.ZERO:
			return assisted

	return last_aim_direction

func receive_hit(amount: float) -> void:
	if _defeated:
		return
	health.apply_damage(amount)

func _on_died() -> void:
	if _defeated:
		return
	_defeated = true
	velocity = Vector2.ZERO
	_external_velocity = Vector2.ZERO
	set_physics_process(false)
	defeated.emit()
	queue_redraw()

func _draw() -> void:
	var outer := Color(0.38, 0.40, 0.45) if _defeated else Color(0.35, 0.78, 1.0)
	if is_dashing():
		outer = Color(0.55, 0.92, 1.0)
	draw_circle(Vector2.ZERO, 13.0, outer)
	draw_circle(Vector2.ZERO, 8.0, Color(0.10, 0.18, 0.28))
	draw_line(Vector2.ZERO, last_aim_direction * 18.0, Color.WHITE, 3.0)
