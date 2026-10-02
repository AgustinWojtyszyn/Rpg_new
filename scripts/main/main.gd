extends Node2D

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const ENEMY_SCENE := preload("res://scenes/enemies/enemy_base.tscn")
const RAPTOR_SCENE := preload("res://scenes/enemies/raptor_scout.tscn")
const ROOT_VINE_SCENE := preload("res://scenes/enemies/root_vine.tscn")
const ORB_STALKER_SCENE := preload("res://scenes/enemies/orb_stalker.tscn")

const ENEMY_DEFINITIONS := [
	preload("res://resources/enemies/raptor_scout.tres"),
	preload("res://resources/enemies/root_vine.tres"),
	preload("res://resources/enemies/orb_stalker.tres"),
	preload("res://resources/enemies/bone_guard.tres"),
	preload("res://resources/enemies/iron_beetle.tres"),
]

@onready var arena: Node2D = $Arena

func _ready() -> void:
	queue_redraw()
	var player := PLAYER_SCENE.instantiate() as PlayerCharacter
	player.position = Vector2(480.0, 270.0)
	arena.add_child(player)

	var spawn_positions := [
		Vector2(180.0, 150.0),
		Vector2(780.0, 150.0),
		Vector2(770.0, 390.0),
		Vector2(190.0, 395.0),
		Vector2(480.0, 90.0),
	]
	for index in range(ENEMY_DEFINITIONS.size()):
		var definition: EnemyDefinition = ENEMY_DEFINITIONS[index]
		var enemy := _scene_for(definition).instantiate() as EnemyBase
		enemy.configure(definition, player)
		enemy.position = spawn_positions[index]
		arena.add_child(enemy)

func _scene_for(definition: EnemyDefinition) -> PackedScene:
	match definition.family:
		EnemyDefinition.Family.DINOSAUR:
			return RAPTOR_SCENE
		EnemyDefinition.Family.PLANT:
			return ROOT_VINE_SCENE
		EnemyDefinition.Family.ALIEN:
			return ORB_STALKER_SCENE
		_:
			return ENEMY_SCENE

func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, 960.0, 540.0), Color(0.055, 0.065, 0.09), true)
	for x in range(0, 961, 48):
		draw_line(Vector2(x, 0), Vector2(x, 540), Color(0.09, 0.10, 0.14), 1.0)
	for y in range(0, 541, 48):
		draw_line(Vector2(0, y), Vector2(960, y), Color(0.09, 0.10, 0.14), 1.0)
	draw_rect(Rect2(8.0, 8.0, 944.0, 524.0), Color(0.30, 0.40, 0.58), false, 2.0)
