extends Node2D

const COMBAT_ROOM_SCENE := preload("res://scenes/dungeon/combat_room.tscn")
const TREX_ROOM_SCENE := preload("res://scenes/dungeon/trex_room_runtime.tscn")
const RIFT_ROOM_SCENE := preload("res://scenes/dungeon/rift_room_runtime.tscn")

const RAPTOR := preload("res://resources/enemies/raptor_scout.tres")
const VINE := preload("res://resources/enemies/root_vine.tres")
const ALIEN := preload("res://resources/enemies/orb_stalker.tres")
const SKELETON := preload("res://resources/enemies/bone_guard.tres")
const BEETLE := preload("res://resources/enemies/iron_beetle.tres")

const OPPOSITE_SLOT := {
	&"north": &"south",
	&"south": &"north",
	&"east": &"west",
	&"west": &"east",
}

@export var run_seed: int = 20261001
@export_range(7, 30, 1) var main_path_rooms: int = 9
@export_range(0, 20, 1) var side_rooms: int = 4

@onready var room_layer: Node2D = $RoomLayer
@onready var player: PlayerCharacter = $PlayerLayer/Player
@onready var status_label: Label = $UI/Status
@onready var victory_label: Label = $UI/Victory

var _layout: Dictionary
var _current_room: RoomBase
var _current_room_id := -1
var _cleared_rooms: Dictionary = {}
var _transitioning := false
var _victory := false

func _ready() -> void:
	_layout = RoomGraphGenerator.new().generate(run_seed, main_path_rooms, side_rooms)
	_enter_room(int(_layout["start_id"]), &"")

func _process(_delta: float) -> void:
	if _current_room_id < 0:
		return
	var room: Dictionary = _layout["rooms"][_current_room_id]
	status_label.text = "Seed %d  ·  Sala %d/%d  ·  %s  ·  HP %d/%d" % [
		run_seed,
		_current_room_id + 1,
		_layout["rooms"].size(),
		String(room["kind"]).to_upper(),
		roundi(player.health.current_health),
		roundi(player.health.max_health),
	]
	victory_label.visible = _victory

func _enter_room(room_id: int, entry_slot: StringName) -> void:
	_transitioning = false
	_clear_transient_projectiles()

	if is_instance_valid(_current_room):
		_current_room.process_mode = Node.PROCESS_MODE_DISABLED
		_current_room.visible = false
		_current_room.position = Vector2(10000, 10000)
		_current_room.queue_free()
		_current_room = null

	_current_room_id = room_id
	var room_data: Dictionary = _layout["rooms"][room_id]
	var already_cleared := _cleared_rooms.has(room_id)
	var kind := StringName(room_data["kind"])

	if already_cleared:
		_current_room = COMBAT_ROOM_SCENE.instantiate() as CombatRoom
		room_layer.add_child(_current_room)
		(_current_room as CombatRoom).setup(room_data, player, [], true)
	elif kind == RoomGraphGenerator.KIND_MINIBOSS:
		_current_room = TREX_ROOM_SCENE.instantiate() as TrexRoomRuntime
		room_layer.add_child(_current_room)
		(_current_room as TrexRoomRuntime).setup(room_data, player, false)
	elif kind == RoomGraphGenerator.KIND_BOSS:
		_current_room = RIFT_ROOM_SCENE.instantiate() as RiftRoomRuntime
		room_layer.add_child(_current_room)
		var rift_room := _current_room as RiftRoomRuntime
		rift_room.setup(room_data, player, _room_seed(room_id), false)
		rift_room.final_boss_defeated.connect(_on_final_boss_defeated)
	else:
		var encounter: Array[EnemyDefinition] = []
		if kind == RoomGraphGenerator.KIND_COMBAT:
			encounter = _build_encounter(room_data)
		_current_room = COMBAT_ROOM_SCENE.instantiate() as CombatRoom
		room_layer.add_child(_current_room)
		(_current_room as CombatRoom).setup(room_data, player, encounter, false)

	_current_room.door_traversed.connect(_on_door_traversed)
	_current_room.room_cleared.connect(_on_room_cleared)

	if _current_room.is_cleared:
		_cleared_rooms[room_id] = true

	player.position = _current_room.spawn_position_for_entry(entry_slot)

func _build_encounter(room_data: Dictionary) -> Array[EnemyDefinition]:
	var depth := int(room_data["depth"])
	var pool := _enemy_pool_for_depth(depth)
	var rng := RandomNumberGenerator.new()
	rng.seed = _room_seed(int(room_data["id"]))
	var budget := mini(18, 5 + depth * 2)
	return EncounterDirector.new().build_encounter(pool, budget, rng, 8)

func _enemy_pool_for_depth(depth: int) -> Array[EnemyDefinition]:
	var pool: Array[EnemyDefinition] = [SKELETON, BEETLE, RAPTOR]
	if depth >= 2:
		pool.append(VINE)
	if depth >= 4:
		pool.append(ALIEN)
	return pool

func _room_seed(room_id: int) -> int:
	return run_seed ^ ((room_id + 1) * 130363)

func _on_room_cleared() -> void:
	_cleared_rooms[_current_room_id] = true

func _on_door_traversed(destination_room_id: int, exit_slot: StringName) -> void:
	if _transitioning:
		return
	_transitioning = true
	var entry_slot: StringName = OPPOSITE_SLOT.get(exit_slot, &"")
	call_deferred("_enter_room", destination_room_id, entry_slot)

func _on_final_boss_defeated() -> void:
	_cleared_rooms[_current_room_id] = true
	_victory = true

func _clear_transient_projectiles() -> void:
	for node in get_tree().get_nodes_in_group("transient_projectile"):
		if node is CollisionObject2D:
			(node as CollisionObject2D).collision_layer = 0
			(node as CollisionObject2D).collision_mask = 0
		node.process_mode = Node.PROCESS_MODE_DISABLED
		node.queue_free()
