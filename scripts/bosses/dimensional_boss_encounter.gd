extends Node2D

const POCKET_ARENA_SCENE := preload("res://scenes/bosses/pocket_arena.tscn")
const RUN_SEED := 20261001

@onready var arena_stack: ArenaStack = $ArenaStack
@onready var base_arena: Node2D = $ArenaStack/BaseArena
@onready var player: PlayerCharacter = $PlayerLayer/Player
@onready var boss = $ArenaStack/BaseArena/RiftWarden
@onready var status_label: Label = $UI/Status

var _encounter_rng: RandomNumberGenerator
var _return_position := Vector2.ZERO
var _inside_pocket := false
var _active_theme: StringName = &""

func _ready() -> void:
	var run_rng := RunRng.new(RUN_SEED)
	_encounter_rng = run_rng.make_stream(RunRng.Stream.ENCOUNTERS)
	arena_stack.register_base_arena(base_arena)
	boss.configure_target(player)
	boss.dimension_cast_requested.connect(_on_dimension_cast_requested)
	boss.boss_died.connect(_on_boss_died)
	queue_redraw()

func _process(_delta: float) -> void:
	if not is_instance_valid(boss):
		return
	if _inside_pocket:
		status_label.text = "RIFT WARDEN · dimensión %s · derrotá la oleada para volver\nHP del boss preservado: %d / %d" % [
			String(_active_theme),
			roundi(boss.health.current_health),
			roundi(boss.health.max_health),
		]
	else:
		status_label.text = "RIFT WARDEN  HP %d / %d   ·   Fase %d\nEl hechizo dimensional NO le da inmunidad: podés dañarlo durante la preparación" % [
			roundi(boss.health.current_health),
			roundi(boss.health.max_health),
			boss.phase_model.current_phase + 1,
		]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_B:
			get_tree().change_scene_to_file("res://scenes/main/main.tscn")

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
	_active_theme = theme
	player.position = Vector2(480.0, 420.0)
	pocket.cleared.connect(_on_pocket_cleared, CONNECT_ONE_SHOT)
	pocket.configure(theme, player, int(_encounter_rng.randi()), budget)

func _on_pocket_cleared() -> void:
	_clear_transient_projectiles()
	arena_stack.pop_arena()
	player.position = _return_position
	_inside_pocket = false
	_active_theme = &""
	if is_instance_valid(boss):
		boss.on_dimension_returned()

func _on_boss_died() -> void:
	status_label.text = "RIFT WARDEN DERROTADO · B vuelve al laboratorio"

func _clear_transient_projectiles() -> void:
	for node in get_tree().get_nodes_in_group("transient_projectile"):
		if node is CollisionObject2D:
			(node as CollisionObject2D).collision_layer = 0
			(node as CollisionObject2D).collision_mask = 0
		node.process_mode = Node.PROCESS_MODE_DISABLED
		node.queue_free()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color(0.055, 0.035, 0.085), true)
	for x in range(0, 961, 64):
		draw_line(Vector2(x, 0), Vector2(x, 540), Color(0.11, 0.07, 0.16), 1.0)
	for y in range(0, 541, 64):
		draw_line(Vector2(0, y), Vector2(960, y), Color(0.11, 0.07, 0.16), 1.0)
	draw_rect(Rect2(24, 42, 912, 464), Color(0.45, 0.20, 0.62), false, 3.0)
