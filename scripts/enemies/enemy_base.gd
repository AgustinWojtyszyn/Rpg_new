class_name EnemyBase
extends CharacterBody2D

@export var definition: EnemyDefinition
@export_range(0.05, 5.0, 0.05) var contact_interval: float = 0.75

@onready var health: HealthComponent = $Health

var target: Node2D
var _contact_cooldown := 0.0

func _ready() -> void:
	if definition != null:
		health.configure(definition.max_health)
	health.died.connect(_on_died)
	queue_redraw()

func configure(new_definition: EnemyDefinition, new_target: Node2D) -> void:
	definition = new_definition
	target = new_target

func _physics_process(delta: float) -> void:
	_tick_contact_cooldown(delta)
	if not _has_valid_target():
		velocity = Vector2.ZERO
		return
	_default_movement()
	move_and_slide()
	_damage_player_on_collision()
	_clamp_to_arena()

func _has_valid_target() -> bool:
	return definition != null and is_instance_valid(target)

func _default_movement() -> void:
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	var direction := to_target.normalized()

	match definition.role:
		EnemyDefinition.Role.RANGED:
			if distance > definition.preferred_range + 24.0:
				velocity = direction * definition.move_speed
			elif distance < definition.preferred_range - 24.0:
				velocity = -direction * definition.move_speed
			else:
				velocity = Vector2.ZERO
		EnemyDefinition.Role.CONTROLLER:
			velocity = Vector2.ZERO
		_:
			velocity = direction * definition.move_speed

func _tick_contact_cooldown(delta: float) -> void:
	_contact_cooldown = maxf(0.0, _contact_cooldown - delta)

func _damage_player_on_collision() -> void:
	if _contact_cooldown > 0.0 or definition == null:
		return
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		var collider := collision.get_collider()
		if collider is Node and collider.has_method("receive_hit"):
			collider.call("receive_hit", definition.contact_damage)
			_contact_cooldown = contact_interval
			return

func _clamp_to_arena() -> void:
	global_position.x = clampf(global_position.x, 16.0, 944.0)
	global_position.y = clampf(global_position.y, 16.0, 524.0)

func receive_hit(amount: float) -> void:
	health.apply_damage(amount)

func _on_died() -> void:
	queue_free()

func _draw() -> void:
	var color := Color(0.9, 0.2, 0.3)
	if definition != null:
		color = definition.placeholder_color
	draw_circle(Vector2.ZERO, 14.0, color)
	draw_circle(Vector2.ZERO, 8.0, color.darkened(0.45))
