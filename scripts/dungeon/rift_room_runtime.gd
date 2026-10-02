class_name RiftRoomRuntime
extends RoomBase

signal final_boss_defeated

const POCKET_ARENA_SCENE := preload("res://scenes/bosses/pocket_arena.tscn")

@onready var arena_stack: ArenaStack = $ArenaStack
@onready var base_arena: Node2D = $ArenaStack/BaseArena
@onready var boss = $ArenaStack/BaseArena/RiftWarden

var _encounter_rng := RandomNumberGenerator.new()
var _return_position := Vector2.ZERO
var _inside_pocket := false

func setup(
	data: Dictionary,
	run_player: PlayerCharacter,
	encounter_seed: int,
	already_cleared: bool
) -> void:
	setup_base(data, run_player, already_cleared)

	if already_cleared:
		$ArenaStack.queue_free()
		return

	_encounter_rng.seed = encounter_seed
	arena_stack.register_base_arena(base_arena)
	boss.configure_target(player)
	boss.dimension_cast_requested.connect(_on_dimension_cast_requested)
	boss.boss_died.connect(_on_boss_died)

func _on_dimension_cast_requested(theme: StringName, budget: int) -> void:
	if _inside_pocket or not is_instance_valid(boss):
		return

	_clear_transient_projectiles()
	_return_position = player.position
	var pocket := arena_stack.push_scene(POCKET_ARENA_SCENE) as PocketArena
	if pocket == null:
		boss.on_dimension_returned()
		return

	_inside_pocket = true
	player.position = Vector2(480, 420)
	pocket.cleared.connect(_on_pocket_cleared, CONNECT_ONE_SHOT)
	pocket.configure(theme, player, int(_encounter_rng.randi()), budget)

func _on_pocket_cleared() -> void:
	_clear_transient_projectiles()
	arena_stack.pop_arena()
	player.position = _return_position
	_inside_pocket = false
	if is_instance_valid(boss):
		boss.on_dimension_returned()

func _on_boss_died() -> void:
	_clear_transient_projectiles()
	mark_cleared()
	final_boss_defeated.emit()

func _clear_transient_projectiles() -> void:
	for node in get_tree().get_nodes_in_group("transient_projectile"):
		if node is CollisionObject2D:
			(node as CollisionObject2D).collision_layer = 0
			(node as CollisionObject2D).collision_mask = 0
		node.process_mode = Node.PROCESS_MODE_DISABLED
		node.queue_free()
