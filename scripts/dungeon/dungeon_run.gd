extends Node2D

const COMBAT_ROOM_SCENE := preload("res://scenes/dungeon/combat_room.tscn")
const CHOICE_ROOM_SCENE := preload("res://scenes/dungeon/choice_room.tscn")
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

@export var run_seed: int = 0
@export_range(7, 30, 1) var main_path_rooms: int = 9
@export_range(0, 20, 1) var side_rooms: int = 4

@onready var room_layer: Node2D = $RoomLayer
@onready var player: PlayerCharacter = $PlayerLayer/Player
@onready var status_label: Label = $UI/Status
@onready var build_label: Label = $UI/Build
@onready var profile_label: Label = $UI/Profile
@onready var toast_label: Label = $UI/Toast
@onready var boss_name_label: Label = $UI/BossName
@onready var boss_health_bar: ProgressBar = $UI/BossHealth
@onready var victory_label: Label = $UI/Victory
@onready var game_over_label: Label = $UI/GameOver
@onready var mobile_controls: MobileControls = $MobileControls

var _layout: Dictionary
var _current_room: RoomBase
var _current_room_id := -1
var _cleared_rooms: Dictionary = {}
var _rewarded_rooms: Dictionary = {}
var _transitioning := false
var _victory := false
var _game_over := false
var _run_finalized := false
var _end_unlock_message := ""
var _toast_time_left := 0.0

var _run_build := RunBuild.new()
var _reward_director := RewardDirector.new()
var _profile: MetaProgression

func _ready() -> void:
	_profile = MetaProgression.load_profile()
	player.defeated.connect(_on_player_defeated)

	var snapshot := RunSaveStore.load_snapshot()
	if snapshot.is_empty():
		_start_new_run()
	else:
		_restore_run(snapshot)

func _process(delta: float) -> void:
	_update_boss_hud()
	_update_toast(delta)

	if _game_over:
		game_over_label.visible = true
		victory_label.visible = false
		if Input.is_action_just_pressed("restart_run"):
			get_tree().reload_current_scene()
		return

	if _victory:
		victory_label.visible = true
		game_over_label.visible = false
		if Input.is_action_just_pressed("restart_run"):
			get_tree().reload_current_scene()
		return

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

func _start_new_run() -> void:
	run_seed = _resolve_new_seed(run_seed)
	_run_build = RunBuild.new()
	_attach_build(_run_build)
	player.configure_build(_run_build)
	_cleared_rooms.clear()
	_rewarded_rooms.clear()
	_layout = RoomGraphGenerator.new().generate(run_seed, main_path_rooms, side_rooms)
	_update_all_hud()
	_enter_room(int(_layout["start_id"]), &"", true)

func _restore_run(snapshot: Dictionary) -> void:
	run_seed = int(snapshot.get("seed", 1))
	_run_build = RunBuild.deserialize(snapshot.get("build", {}))
	_attach_build(_run_build)
	player.configure_build(_run_build)

	_cleared_rooms = _array_to_set(snapshot.get("cleared_room_ids", []))
	_rewarded_rooms = _array_to_set(snapshot.get("rewarded_room_ids", []))
	_layout = RoomGraphGenerator.new().generate(run_seed, main_path_rooms, side_rooms)

	var room_id := int(snapshot.get("current_room_id", 0))
	if room_id < 0 or room_id >= _layout["rooms"].size():
		RunSaveStore.clear()
		_start_new_run()
		return

	_update_all_hud()
	_enter_room(room_id, &"", false)

	var health_value := float(snapshot.get("player_health", player.health.max_health))
	player.health.current_health = clampf(health_value, 1.0, player.health.max_health)

	var raw_position = snapshot.get("player_position", [])
	if raw_position is Array and raw_position.size() >= 2:
		player.position = Vector2(float(raw_position[0]), float(raw_position[1]))

	_update_all_hud()
	_show_toast("RUN RESTAURADA", 1.8)

func _attach_build(build: RunBuild) -> void:
	if build.changed.is_connected(_on_build_changed):
		return
	build.changed.connect(_on_build_changed)

func _resolve_new_seed(configured_seed: int) -> int:
	if configured_seed != 0:
		return configured_seed
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return maxi(1, int(rng.randi()))

func _enter_room(room_id: int, entry_slot: StringName, save_checkpoint: bool = true) -> void:
	if _game_over or _victory:
		return

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

	match kind:
		RoomGraphGenerator.KIND_TREASURE:
			_enter_treasure_room(room_data, already_cleared)
		RoomGraphGenerator.KIND_EVENT:
			_enter_event_room(room_data, already_cleared)
		RoomGraphGenerator.KIND_MINIBOSS:
			_current_room = TREX_ROOM_SCENE.instantiate() as TrexRoomRuntime
			room_layer.add_child(_current_room)
			(_current_room as TrexRoomRuntime).setup(room_data, player, already_cleared)
		RoomGraphGenerator.KIND_BOSS:
			_current_room = RIFT_ROOM_SCENE.instantiate() as RiftRoomRuntime
			room_layer.add_child(_current_room)
			var rift_room := _current_room as RiftRoomRuntime
			rift_room.setup(room_data, player, _room_seed(room_id, 79), already_cleared)
			if not already_cleared:
				rift_room.final_boss_defeated.connect(_on_final_boss_defeated)
		_:
			var encounter: Array[EnemyDefinition] = []
			if kind == RoomGraphGenerator.KIND_COMBAT and not already_cleared:
				encounter = _build_encounter(room_data)
			_current_room = COMBAT_ROOM_SCENE.instantiate() as CombatRoom
			room_layer.add_child(_current_room)
			(_current_room as CombatRoom).setup(
				room_data,
				player,
				encounter,
				already_cleared or kind == RoomGraphGenerator.KIND_START
			)

	_current_room.door_traversed.connect(_on_door_traversed)
	_current_room.room_cleared.connect(_on_room_cleared)

	if _current_room.is_cleared:
		_cleared_rooms[room_id] = true

	player.position = _current_room.spawn_position_for_entry(entry_slot)

	if save_checkpoint:
		_save_checkpoint()

func _enter_treasure_room(room_data: Dictionary, already_cleared: bool) -> void:
	var options: Array[Dictionary] = []
	if not already_cleared:
		var rng := RandomNumberGenerator.new()
		rng.seed = _room_seed(int(room_data["id"]), 211)
		options = _reward_director.build_treasure_options(
			_run_build,
			rng,
			_available_weapon_ids(),
			3
		)

	var choice_room := CHOICE_ROOM_SCENE.instantiate() as ChoiceRoom
	_current_room = choice_room
	room_layer.add_child(choice_room)
	choice_room.setup(
		room_data,
		player,
		"Cámara de anomalías",
		"Elegí una recompensa. Las otras se perderán al abrirse las puertas.",
		options,
		already_cleared
	)
	if not already_cleared:
		choice_room.option_chosen.connect(_on_choice_selected)

func _enter_event_room(room_data: Dictionary, already_cleared: bool) -> void:
	var heading := "Evento resuelto"
	var blurb := "Ya tomaste una decisión en esta sala."
	var options: Array[Dictionary] = []

	if not already_cleared:
		var rng := RandomNumberGenerator.new()
		rng.seed = _room_seed(int(room_data["id"]), 353)
		var event := _reward_director.build_event(_run_build, rng, _available_weapon_ids())
		heading = String(event.get("title", "Evento"))
		blurb = String(event.get("description", ""))
		for raw_option in event.get("options", []):
			if raw_option is Dictionary:
				options.append(raw_option)

	var choice_room := CHOICE_ROOM_SCENE.instantiate() as ChoiceRoom
	_current_room = choice_room
	room_layer.add_child(choice_room)
	choice_room.setup(room_data, player, heading, blurb, options, already_cleared)
	if not already_cleared:
		choice_room.option_chosen.connect(_on_choice_selected)

func _build_encounter(room_data: Dictionary) -> Array[EnemyDefinition]:
	var depth := int(room_data["depth"])
	var pool := _enemy_pool_for_depth(depth)
	var rng := RandomNumberGenerator.new()
	rng.seed = _room_seed(int(room_data["id"]), 17)
	var budget := mini(18, 5 + depth * 2)
	return EncounterDirector.new().build_encounter(pool, budget, rng, 8)

func _enemy_pool_for_depth(depth: int) -> Array[EnemyDefinition]:
	var pool: Array[EnemyDefinition] = [SKELETON, BEETLE, RAPTOR]
	if depth >= 2:
		pool.append(VINE)
	if depth >= 4:
		pool.append(ALIEN)
	return pool

func _available_weapon_ids() -> Array[StringName]:
	return _profile.get_unlocked_weapon_ids()

func _room_seed(room_id: int, salt: int) -> int:
	return run_seed ^ ((room_id + 1) * 130363) ^ salt

func _on_choice_selected(option: Dictionary) -> void:
	var kind := StringName(option.get("kind", &""))
	var feedback := String(option.get("name", option.get("title", "Recompensa")))
	match kind:
		&"weapon":
			var weapon := option.get("resource") as WeaponDefinition
			if weapon != null:
				player.equip_weapon(weapon)
		&"modifier":
			var modifier := option.get("resource") as RunModifierDefinition
			if modifier != null:
				player.add_modifier(modifier)
		&"effect":
			_apply_effect(option)
	_show_toast(feedback, 2.0)

func _apply_effect(option: Dictionary) -> void:
	var effect := StringName(option.get("effect", &""))
	var payload: Dictionary = option.get("payload", {})
	match effect:
		&"heal":
			player.health.apply_heal(float(payload.get("amount", 0.0)))
		&"essence":
			_run_build.add_essence(int(payload.get("amount", 0)))

func _on_room_cleared() -> void:
	if _cleared_rooms.has(_current_room_id):
		return
	_cleared_rooms[_current_room_id] = true
	_award_room_essence(_current_room_id)
	_save_checkpoint()

func _award_room_essence(room_id: int) -> void:
	if _rewarded_rooms.has(room_id):
		return
	_rewarded_rooms[room_id] = true

	var room: Dictionary = _layout["rooms"][room_id]
	var kind := StringName(room["kind"])
	var depth := int(room["depth"])
	var amount := 0
	match kind:
		RoomGraphGenerator.KIND_COMBAT:
			amount = 4 + depth
		RoomGraphGenerator.KIND_MINIBOSS:
			amount = 18
		RoomGraphGenerator.KIND_BOSS:
			amount = 40

	if amount > 0:
		_run_build.add_essence(amount)
		_show_toast("+%d ESENCIA" % amount, 1.5)

func _on_build_changed() -> void:
	_update_build_hud()

func _update_all_hud() -> void:
	_update_build_hud()
	_update_profile_hud()

func _update_build_hud() -> void:
	if not is_node_ready():
		return
	var weapon_name := "Sin arma"
	if _run_build.weapon != null:
		weapon_name = _run_build.weapon.display_name
	build_label.text = "%s  ·  Reliquias %d  ·  Esencia %d" % [
		weapon_name,
		_run_build.modifiers.size(),
		_run_build.essence,
	]

func _update_profile_hud() -> void:
	if not is_node_ready() or _profile == null:
		return
	profile_label.text = "Meta %d esencia  ·  Victorias %d  ·  Armas %d/%d" % [
		_profile.lifetime_essence,
		_profile.completed_runs,
		_profile.unlocked_weapon_ids.size(),
		WeaponCatalog.all().size(),
	]

func _update_boss_hud() -> void:
	if not is_instance_valid(_current_room):
		boss_name_label.visible = false
		boss_health_bar.visible = false
		return

	var boss := _current_room.get_boss()
	if boss == null:
		boss_name_label.visible = false
		boss_health_bar.visible = false
		return

	boss_name_label.visible = true
	boss_health_bar.visible = true
	boss_name_label.text = boss.display_name
	boss_health_bar.value = boss.get_health_ratio() * 100.0

func _on_door_traversed(destination_room_id: int, exit_slot: StringName) -> void:
	if _transitioning or _game_over or _victory:
		return
	_transitioning = true
	var entry_slot: StringName = OPPOSITE_SLOT.get(exit_slot, &"")
	call_deferred("_enter_room", destination_room_id, entry_slot, true)

func _on_player_defeated() -> void:
	if _game_over or _victory:
		return
	_game_over = true
	_transitioning = true
	_clear_transient_projectiles()
	if is_instance_valid(_current_room):
		_current_room.process_mode = Node.PROCESS_MODE_DISABLED

	_finalize_run(false)
	status_label.text = "RUN TERMINADA · R para reintentar"
	game_over_label.text = "RUN TERMINADA\nEsencia obtenida: %d%s\nR / RETRY para reintentar" % [
		_run_build.essence,
		_end_unlock_message,
	]
	mobile_controls.show_end_state()

func _on_final_boss_defeated() -> void:
	if _game_over:
		return
	_cleared_rooms[_current_room_id] = true
	_award_room_essence(_current_room_id)
	_victory = true
	_transitioning = true
	_clear_transient_projectiles()
	player.set_physics_process(false)
	if is_instance_valid(_current_room):
		_current_room.process_mode = Node.PROCESS_MODE_DISABLED

	_finalize_run(true)
	status_label.text = "RIFT WARDEN DERROTADO · RUN COMPLETADA"
	victory_label.text = "RIFT WARDEN DERROTADO\nRUN COMPLETADA · %d esencia%s\nR / RETRY para una nueva seed" % [
		_run_build.essence,
		_end_unlock_message,
	]
	mobile_controls.show_end_state()

func _finalize_run(victory: bool) -> void:
	if _run_finalized:
		return
	_run_finalized = true
	RunSaveStore.clear()
	var unlocked := _profile.record_run(victory, _run_build.essence)
	_end_unlock_message = _format_unlock_message(unlocked)
	_update_profile_hud()

func _format_unlock_message(unlocked_ids: Array[StringName]) -> String:
	if unlocked_ids.is_empty():
		return ""
	var names: Array[String] = []
	for id_value in unlocked_ids:
		var weapon := WeaponCatalog.get_by_id(id_value)
		names.append(weapon.display_name if weapon != null else String(id_value))
	return "\nNUEVO DESBLOQUEO: %s" % ", ".join(names)

func _save_checkpoint() -> void:
	if _game_over or _victory or _current_room_id < 0:
		return
	var snapshot := {
		"seed": run_seed,
		"current_room_id": _current_room_id,
		"cleared_room_ids": _set_to_array(_cleared_rooms),
		"rewarded_room_ids": _set_to_array(_rewarded_rooms),
		"build": _run_build.serialize(),
		"player_health": player.health.current_health,
		"player_position": [player.position.x, player.position.y],
	}
	RunSaveStore.save_snapshot(snapshot)

func _set_to_array(source: Dictionary) -> Array[int]:
	var result: Array[int] = []
	for raw_key in source.keys():
		result.append(int(raw_key))
	result.sort()
	return result

func _array_to_set(source) -> Dictionary:
	var result: Dictionary = {}
	if source is not Array:
		return result
	for raw_value in source:
		result[int(raw_value)] = true
	return result

func _show_toast(message: String, duration: float = 1.6) -> void:
	if not is_node_ready() or message.is_empty():
		return
	toast_label.text = message
	toast_label.visible = true
	toast_label.modulate = Color.WHITE
	_toast_time_left = maxf(0.1, duration)

func _update_toast(delta: float) -> void:
	if _toast_time_left <= 0.0:
		toast_label.visible = false
		return
	_toast_time_left = maxf(0.0, _toast_time_left - delta)
	var alpha := clampf(_toast_time_left * 2.0, 0.0, 1.0)
	toast_label.modulate = Color(1.0, 1.0, 1.0, alpha)

func _clear_transient_projectiles() -> void:
	for node in get_tree().get_nodes_in_group("transient_projectile"):
		if node is CollisionObject2D:
			(node as CollisionObject2D).collision_layer = 0
			(node as CollisionObject2D).collision_mask = 0
		node.process_mode = Node.PROCESS_MODE_DISABLED
		node.queue_free()
