class_name PlayerCharacter
extends CharacterBody2D

signal interact_requested
signal defeated
signal build_changed

@export_range(10.0, 1000.0, 1.0) var move_speed: float = 220.0
@export_range(10.0, 1500.0, 1.0) var dash_speed: float = 560.0
@export_range(0.05, 1.0, 0.01) var dash_duration: float = 0.14
@export_range(0.1, 5.0, 0.05) var dash_cooldown: float = 0.85
@export_range(0.05, 2.0, 0.05) var hurt_invulnerability: float = 0.35
@export var dash_invulnerable: bool = true
@export var aim_assist_enabled: bool = true
@export_range(50.0, 1000.0, 10.0) var aim_assist_range: float = 460.0
@export var projectile_scene: PackedScene

@onready var health: HealthComponent = $Health

var last_aim_direction := Vector2.RIGHT
var run_build: RunBuild = RunBuild.new()

var _base_max_health := 100.0
var _external_velocity := Vector2.ZERO
var _dash_direction := Vector2.RIGHT
var _dash_time_left := 0.0
var _dash_cooldown_left := 0.0
var _hurt_invulnerability_left := 0.0
var _weapon_cooldown_left := 0.0
var _burst_interval_left := 0.0
var _burst_shots_left := 0
var _defeated := false

func _ready() -> void:
	_base_max_health = health.max_health
	health.died.connect(_on_died)
	configure_build(run_build)
	queue_redraw()

func configure_build(build: RunBuild) -> void:
	if build == null:
		build = RunBuild.new()

	if run_build != null and run_build.changed.is_connected(_on_run_build_changed):
		run_build.changed.disconnect(_on_run_build_changed)

	run_build = build
	if not run_build.changed.is_connected(_on_run_build_changed):
		run_build.changed.connect(_on_run_build_changed)
	_refresh_build_stats()
	build_changed.emit()

func equip_weapon(definition: WeaponDefinition) -> bool:
	if not run_build.equip_weapon(definition):
		return false
	_weapon_cooldown_left = 0.0
	_burst_shots_left = 0
	return true

func add_modifier(definition: RunModifierDefinition) -> bool:
	if not run_build.add_modifier(definition):
		return false
	if definition.heal_on_pickup > 0.0:
		health.apply_heal(definition.heal_on_pickup)
	return true

func _physics_process(delta: float) -> void:
	if _defeated:
		velocity = Vector2.ZERO
		return

	_dash_cooldown_left = maxf(0.0, _dash_cooldown_left - delta)
	_dash_time_left = maxf(0.0, _dash_time_left - delta)
	_hurt_invulnerability_left = maxf(0.0, _hurt_invulnerability_left - delta)
	_weapon_cooldown_left = maxf(0.0, _weapon_cooldown_left - delta)
	_burst_interval_left = maxf(0.0, _burst_interval_left - delta)

	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector != Vector2.ZERO:
		last_aim_direction = input_vector.normalized()

	if Input.is_action_just_pressed("dash") and _dash_cooldown_left <= 0.0:
		_dash_direction = input_vector.normalized() if input_vector != Vector2.ZERO else last_aim_direction
		_dash_time_left = dash_duration
		_dash_cooldown_left = dash_cooldown * run_build.dash_cooldown_multiplier()

	if Input.is_action_just_pressed("interact"):
		interact_requested.emit()

	if _dash_time_left > 0.0:
		velocity = _dash_direction * dash_speed + _external_velocity * 0.25
	else:
		velocity = input_vector * move_speed * run_build.move_speed_multiplier() + _external_velocity

	move_and_slide()
	_external_velocity = _external_velocity.move_toward(Vector2.ZERO, 900.0 * delta)

	if _burst_shots_left > 0 and _burst_interval_left <= 0.0:
		_fire_salvo()
		_burst_shots_left -= 1
		if _burst_shots_left > 0:
			_burst_interval_left = run_build.weapon.burst_interval

	if Input.is_action_pressed("attack") and _weapon_cooldown_left <= 0.0 and _burst_shots_left == 0:
		_start_attack()

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
	_hurt_invulnerability_left = 0.0
	_weapon_cooldown_left = 0.0
	_burst_shots_left = 0
	_defeated = false
	health.reset()
	set_physics_process(true)
	queue_redraw()

func _start_attack() -> void:
	if projectile_scene == null or run_build.weapon == null:
		return
	_weapon_cooldown_left = run_build.weapon.fire_cooldown * run_build.fire_cooldown_multiplier()
	_fire_salvo()
	_burst_shots_left = maxi(0, run_build.weapon.burst_count - 1)
	if _burst_shots_left > 0:
		_burst_interval_left = run_build.weapon.burst_interval

func _fire_salvo() -> void:
	var weapon := run_build.weapon
	if weapon == null:
		return

	var attack_direction := _get_attack_direction()
	last_aim_direction = attack_direction

	var count := maxi(1, weapon.projectile_count + run_build.projectile_count_bonus())
	var spread := weapon.spread_degrees
	if count > 1 and spread <= 0.0:
		spread = 10.0 * float(count - 1)

	for index in range(count):
		var angle_offset := 0.0
		if count > 1:
			var t := float(index) / float(count - 1)
			angle_offset = deg_to_rad(lerpf(-spread * 0.5, spread * 0.5, t))

		var shot_direction := attack_direction.rotated(angle_offset)
		var projectile := projectile_scene.instantiate() as Projectile
		if projectile == null:
			continue

		projectile.configure_shot(
			weapon.damage * run_build.damage_multiplier(),
			weapon.projectile_speed * run_build.projectile_speed_multiplier(),
			weapon.projectile_lifetime,
			weapon.pierce_count,
			weapon.explosion_radius * run_build.explosion_radius_multiplier(),
			weapon.projectile_radius,
			weapon.projectile_color
		)
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = global_position + shot_direction * 20.0
		projectile.launch(shot_direction)

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
	if _defeated or amount <= 0.0:
		return
	if dash_invulnerable and is_dashing():
		return
	if _hurt_invulnerability_left > 0.0:
		return

	var applied := health.apply_damage(amount)
	if applied > 0.0 and not _defeated:
		_hurt_invulnerability_left = hurt_invulnerability + run_build.hurt_invulnerability_bonus()

func _on_run_build_changed() -> void:
	_refresh_build_stats()
	build_changed.emit()

func _refresh_build_stats() -> void:
	var previous_health := health.current_health
	var new_max := _base_max_health * run_build.max_health_multiplier()
	health.configure(new_max, false)
	health.current_health = minf(new_max, previous_health)

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
	var outer := Color(0.35, 0.78, 1.0)
	if _defeated:
		outer = Color(0.38, 0.40, 0.45)
	elif is_dashing():
		outer = Color(0.55, 0.92, 1.0)
	elif _hurt_invulnerability_left > 0.0:
		outer = Color(1.0, 0.72, 0.72)

	var weapon_color := Color(0.82, 0.90, 1.0)
	if run_build != null and run_build.weapon != null:
		weapon_color = run_build.weapon.projectile_color

	draw_circle(Vector2(2, 5), 15.0, Color(0.0, 0.0, 0.0, 0.24))
	draw_circle(Vector2.ZERO, 14.0, outer.darkened(0.28))
	draw_circle(Vector2.ZERO, 12.0, outer)
	draw_circle(Vector2.ZERO, 7.0, Color(0.08, 0.12, 0.20))
	draw_line(last_aim_direction * 7.0, last_aim_direction * 23.0, weapon_color.darkened(0.28), 6.0)
	draw_line(last_aim_direction * 8.0, last_aim_direction * 24.0, weapon_color, 3.0)
	draw_circle(last_aim_direction * 24.0, 3.0, weapon_color.lightened(0.24))

	if is_dashing():
		draw_arc(Vector2.ZERO, 20.0, 0.0, TAU, 28, Color(0.62, 0.96, 1.0, 0.72), 3.0)
