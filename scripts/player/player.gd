class_name PlayerCharacter
extends CharacterBody2D

@export_range(10.0, 1000.0, 1.0) var move_speed: float = 220.0
@export var projectile_scene: PackedScene

@onready var health: HealthComponent = $Health

var last_aim_direction := Vector2.RIGHT

func _ready() -> void:
	health.died.connect(_on_died)
	queue_redraw()

func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector != Vector2.ZERO:
		last_aim_direction = input_vector.normalized()
	velocity = input_vector * move_speed
	move_and_slide()

	if Input.is_action_just_pressed("ui_accept"):
		_fire()

	global_position.x = clampf(global_position.x, 20.0, 940.0)
	global_position.y = clampf(global_position.y, 20.0, 520.0)

func _fire() -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate() as Projectile
	if projectile == null:
		return
	projectile.global_position = global_position + last_aim_direction * 20.0
	projectile.launch(last_aim_direction)
	get_tree().current_scene.add_child(projectile)

func receive_hit(amount: float) -> void:
	health.apply_damage(amount)

func _on_died() -> void:
	global_position = Vector2(480.0, 270.0)
	health.reset()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 13.0, Color(0.35, 0.78, 1.0))
	draw_circle(Vector2.ZERO, 8.0, Color(0.10, 0.18, 0.28))
	draw_line(Vector2.ZERO, last_aim_direction * 18.0, Color.WHITE, 3.0)
