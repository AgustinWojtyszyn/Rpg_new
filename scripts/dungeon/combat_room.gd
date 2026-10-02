class_name CombatRoom
extends RoomBase

const SPAWN_POSITIONS := [
	Vector2(190, 150),
	Vector2(370, 128),
	Vector2(590, 128),
	Vector2(770, 150),
	Vector2(190, 370),
	Vector2(370, 392),
	Vector2(590, 392),
	Vector2(770, 370),
]

var _living_enemies := 0
var _registry := EnemySceneRegistry.new()

func setup(
	data: Dictionary,
	run_player: PlayerCharacter,
	encounter: Array[EnemyDefinition],
	already_cleared: bool
) -> void:
	var clear_at_start := already_cleared or encounter.is_empty()
	setup_base(data, run_player, clear_at_start)

	if clear_at_start:
		return

	for index in range(mini(encounter.size(), SPAWN_POSITIONS.size())):
		var definition := encounter[index]
		var enemy := _registry.scene_for(definition).instantiate() as EnemyBase
		enemy.configure(definition, player)
		enemy.position = SPAWN_POSITIONS[index]
		add_child(enemy)
		_living_enemies += 1
		enemy.health.died.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	_living_enemies = maxi(0, _living_enemies - 1)
	if _living_enemies == 0:
		mark_cleared()
