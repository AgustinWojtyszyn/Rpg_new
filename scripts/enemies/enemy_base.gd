class_name EnemyBase
extends CharacterBody2D

@export var definition: EnemyDefinition
@export_range(0.05, 5.0, 0.05) var contact_interval: float = 0.75

@onready var health: HealthComponent = $Health

var target: Node2D
var _contact_cooldown := 0.0
var _art_sprite: Sprite2D
var _art_base_path := ""

func _ready() -> void:
	add_to_group("aim_targets")
	if definition != null:
		health.configure(definition.max_health)
	health.died.connect(_on_died)
	_setup_generated_art()
	queue_redraw()

func _process(_delta: float) -> void:
	if not is_instance_valid(_art_sprite) or _art_base_path.is_empty():
		return
	var facing := velocity
	if facing.length_squared() < 1.0 and is_instance_valid(target):
		facing = target.global_position - global_position
	GeneratedArt.update_direction(_art_sprite, _art_base_path, facing)

func configure(new_definition: EnemyDefinition, new_target: Node2D) -> void:
	definition = new_definition
	target = new_target
	_setup_generated_art()

func _setup_generated_art() -> void:
	if definition == null:
		return
	_art_base_path = _generated_art_path(definition.id)
	if _art_base_path.is_empty():
		return
	if not is_instance_valid(_art_sprite):
		_art_sprite = GeneratedArt.make_sprite(_art_base_path, _generated_art_scale(definition.id), 8)
		add_child(_art_sprite)

func _generated_art_path(enemy_id: StringName) -> String:
	match enemy_id:
		&"raptor_scout":
			return "res://assets/generated/enemies/enemy_raptor_final"
		&"root_vine":
			return "res://assets/generated/enemies/enemy_root_vine_final"
		&"orb_stalker":
			return "res://assets/generated/enemies/enemy_orb_stalker_final"
		&"bone_guard":
			return "res://assets/generated/enemies/enemy_bone_guard_final"
		&"iron_beetle":
			return "res://assets/generated/enemies/enemy_beetle_final"
		_:
			return ""

func _generated_art_scale(enemy_id: StringName) -> float:
	match enemy_id:
		&"root_vine":
			return 0.86
		&"iron_beetle":
			return 0.82
		_:
			return 0.78

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

func receive_projectile_hit(amount: float, _source_position: Vector2) -> void:
	receive_hit(amount)

func _on_died() -> void:
	queue_free()

func _draw() -> void:
	var color := Color(0.9, 0.2, 0.3)
	if definition != null:
		color = definition.placeholder_color
	draw_circle(Vector2.ZERO, 14.0, color)
	draw_circle(Vector2.ZERO, 8.0, color.darkened(0.45))
