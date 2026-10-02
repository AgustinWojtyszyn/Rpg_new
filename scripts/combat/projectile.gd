class_name Projectile
extends Area2D

@export_range(1.0, 2000.0, 1.0) var speed: float = 520.0
@export_range(0.1, 1000.0, 0.1) var damage: float = 12.0
@export_range(0.1, 10.0, 0.1) var lifetime: float = 1.4
@export var visual_color: Color = Color(1.0, 0.78, 0.20)

var direction := Vector2.RIGHT

func _ready() -> void:
	add_to_group("transient_projectile")
	body_entered.connect(_on_body_entered)
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
	if body.has_method("receive_projectile_hit"):
		body.call("receive_projectile_hit", damage, global_position)
		queue_free()
	elif body.has_method("receive_hit"):
		body.call("receive_hit", damage)
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.5, visual_color)
	draw_circle(Vector2.ZERO, 2.0, Color.WHITE)
