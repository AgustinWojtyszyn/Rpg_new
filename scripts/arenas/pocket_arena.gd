class_name PocketArena
extends Node2D

signal cleared

const RAPTOR := preload("res://resources/enemies/raptor_scout.tres")
const VINE := preload("res://resources/enemies/root_vine.tres")
const ALIEN := preload("res://resources/enemies/orb_stalker.tres")
const SKELETON := preload("res://resources/enemies/bone_guard.tres")
const BEETLE := preload("res://resources/enemies/iron_beetle.tres")

var theme: StringName = &"mixed"
var player: PlayerCharacter
var _living_enemies := 0
var _configured := false

func configure(
	new_theme: StringName,
	new_player: PlayerCharacter,
	seed_value: int,
	budget: int
) -> void:
	if _configured:
		return
	_configured = true
	theme = new_theme
	player = new_player

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var director := EncounterDirector.new()
	var registry := EnemySceneRegistry.new()
	var pool := _pool_for_theme(theme)
	var encounter := director.build_encounter(pool, budget, rng, $SpawnPoints.get_child_count())

	var spawn_points := $SpawnPoints.get_children()
	for index in range(encounter.size()):
		var definition: EnemyDefinition = encounter[index]
		var enemy := registry.scene_for(definition).instantiate() as EnemyBase
		enemy.configure(definition, player)
		enemy.position = (spawn_points[index] as Node2D).position
		$Enemies.add_child(enemy)
		_living_enemies += 1
		enemy.tree_exited.connect(_on_enemy_exited)

	if _living_enemies == 0:
		cleared.emit()

	queue_redraw()

func _on_enemy_exited() -> void:
	_living_enemies = maxi(0, _living_enemies - 1)
	if _living_enemies == 0:
		cleared.emit()

func _pool_for_theme(value: StringName) -> Array[EnemyDefinition]:
	match value:
		&"prehistoric":
			return [RAPTOR, BEETLE]
		&"overgrowth":
			return [VINE, SKELETON, RAPTOR]
		&"alien":
			return [ALIEN, BEETLE, SKELETON]
		_:
			return [RAPTOR, VINE, ALIEN, SKELETON, BEETLE]

func _draw() -> void:
	var background := Color(0.07, 0.07, 0.10)
	match theme:
		&"prehistoric":
			background = Color(0.08, 0.16, 0.08)
		&"overgrowth":
			background = Color(0.05, 0.18, 0.11)
		&"alien":
			background = Color(0.10, 0.05, 0.18)

	draw_rect(Rect2(0, 0, 960, 540), background, true)
	for x in range(0, 961, 64):
		draw_line(Vector2(x, 0), Vector2(x, 540), background.lightened(0.12), 1.0)
	for y in range(0, 541, 64):
		draw_line(Vector2(0, y), Vector2(960, y), background.lightened(0.12), 1.0)
	draw_rect(Rect2(22, 42, 916, 464), background.lightened(0.28), false, 3.0)
