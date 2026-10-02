class_name Projectile
extends Area2D

@export_range(1.0, 2000.0, 1.0) var speed: float = 520.0
@export_range(0.1, 1000.0, 0.1) var damage: float = 12.0
@export_range(0.1, 10.0, 0.1) var lifetime: float = 1.4
@export_range(0, 8, 1) var pierce_count: int = 0
@export_range(0.0, 180.0, 1.0) var explosion_radius: float = 0.0
@export_range(2.0, 18.0, 0.5) var projectile_radius: float = 4.5
@export var visual_color: Color = Color(1.0, 0.78, 0.20)

var direction := Vector2.RIGHT
var _hit_count := 0
var _hit_instance_ids: Dictionary = {}

func _ready() -> void:
	add_to_group("transient_projectile")
	body_entered.connect(_on_body_entered)
	_apply_collision_radius()
	queue_redraw()

func configure_shot(
	new_damage: float,
	new_speed: float,
	new_lifetime: float,
	new_pierce_count: int,
	new_explosion_radius: float,
	new_radius: float,
	new_color: Color
) -> void:
	damage = maxf(0.1, new_damage)
	speed = maxf(1.0, new_speed)
	lifetime = maxf(0.05, new_lifetime)
	pierce_count = maxi(0, new_pierce_count)
	explosion_radius = maxf(0.0, new_explosion_radius)
	projectile_radius = clampf(new_radius, 2.0, 18.0)
	visual_color = new_color
	if is_node_ready():
		_apply_collision_radius()
		queue_redraw()

func launch(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body == null:
		return

	var instance_id := body.get_instance_id()
	if _hit_instance_ids.has(instance_id):
		return
	_hit_instance_ids[instance_id] = true

	if explosion_radius > 0.0:
		_explode()
		queue_free()
		return

	_apply_damage_to(body)
	_hit_count += 1
	if _hit_count > pierce_count:
		queue_free()

func _apply_damage_to(body: Node) -> void:
	if body.has_method("receive_projectile_hit"):
		body.call("receive_projectile_hit", damage, global_position)
	elif body.has_method("receive_hit"):
		body.call("receive_hit", damage)

func _explode() -> void:
	var circle := CircleShape2D.new()
	circle.radius = explosion_radius

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0.0, global_position)
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var hits := get_world_2d().direct_space_state.intersect_shape(query, 32)
	var damaged: Dictionary = {}
	for hit in hits:
		var collider = hit.get("collider")
		if collider is not Node:
			continue
		var node := collider as Node
		var instance_id := node.get_instance_id()
		if damaged.has(instance_id):
			continue
		damaged[instance_id] = true
		_apply_damage_to(node)

func _apply_collision_radius() -> void:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null:
		return
	var shape := collision.shape as CircleShape2D
	if shape == null:
		return
	var unique_shape := shape.duplicate() as CircleShape2D
	unique_shape.radius = projectile_radius
	collision.shape = unique_shape

func _draw() -> void:
	var tail_length := clampf(speed * 0.035, 10.0, 34.0)
	draw_line(
		Vector2.ZERO,
		-direction * tail_length,
		Color(visual_color.r, visual_color.g, visual_color.b, 0.24),
		maxf(2.0, projectile_radius * 1.25)
	)
	draw_circle(Vector2.ZERO, projectile_radius + 2.0, Color(visual_color.r, visual_color.g, visual_color.b, 0.18))
	draw_circle(Vector2.ZERO, projectile_radius, visual_color)
	draw_circle(Vector2.ZERO, maxf(1.5, projectile_radius * 0.42), Color.WHITE)
	if explosion_radius > 0.0:
		draw_arc(Vector2.ZERO, projectile_radius + 5.0, 0.0, TAU, 20, Color(visual_color.r, visual_color.g, visual_color.b, 0.62), 2.0)
