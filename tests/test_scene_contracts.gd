extends RefCounted

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const MOBILE_CONTROLS_SCENE := preload("res://scenes/ui/mobile_controls.tscn")
const DUNGEON_RUN_SCENE := preload("res://scenes/dungeon/dungeon_run.tscn")
const TREX_ROOM_SCENE := preload("res://scenes/dungeon/trex_room_runtime.tscn")
const RIFT_ROOM_SCENE := preload("res://scenes/dungeon/rift_room_runtime.tscn")
const TREX_BOSS_SCENE := preload("res://scenes/bosses/trex_boss.tscn")
const RIFT_BOSS_SCENE := preload("res://scenes/bosses/rift_warden.tscn")
const BREAKABLE_WALL_SCENE := preload("res://scenes/bosses/breakable_wall.tscn")
const CHOICE_ROOM_SCENE := preload("res://scenes/dungeon/choice_room.tscn")
const CHOICE_PEDESTAL_SCENE := preload("res://scenes/rewards/choice_pedestal.tscn")

func run() -> Array[String]:
	var failures: Array[String] = []

	_validate_input_contracts(failures)
	_validate_player_contracts(failures)
	_validate_mobile_contracts(failures)
	_validate_boss_contracts(failures)
	_validate_run_scene_contracts(failures)

	return failures

func _validate_input_contracts(failures: Array[String]) -> void:
	for action in [&"attack", &"dash", &"interact", &"restart_run"]:
		if not InputMap.has_action(action):
			failures.append("Missing InputMap action: %s" % String(action))

	var main_scene := String(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene != "res://scenes/dungeon/dungeon_run.tscn":
		failures.append("Dungeon run must remain the startup scene.")

	var orientation := int(ProjectSettings.get_setting("display/window/handheld/orientation", -1))
	if orientation != 0:
		failures.append("Mobile orientation must be landscape.")

func _validate_player_contracts(failures: Array[String]) -> void:
	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	if player == null:
		failures.append("Player scene did not instantiate as CharacterBody2D.")
		return

	if player.collision_layer != 1:
		failures.append("Player must remain on collision layer 1.")
	if (player.collision_mask & 2) == 0:
		failures.append("Player must collide with enemy layer 2.")
	if (player.collision_mask & 16) == 0:
		failures.append("Player must collide with scripted set-piece layer 16.")

	player.free()

func _validate_mobile_contracts(failures: Array[String]) -> void:
	var controls := MOBILE_CONTROLS_SCENE.instantiate()
	if controls == null:
		failures.append("Mobile controls scene failed to instantiate.")
		return

	var joystick := controls.get_node_or_null("Root/MoveJoystick")
	var restart := controls.get_node_or_null("Root/Restart")
	if joystick == null or joystick is not VirtualJoystick:
		failures.append("Mobile controls require Godot 4.7 VirtualJoystick.")
	if restart == null or restart is not TouchScreenButton:
		failures.append("Mobile controls require a touch restart button.")
	elif String((restart as TouchScreenButton).action) != "restart_run":
		failures.append("Mobile restart button must emit restart_run.")

	controls.free()

func _validate_boss_contracts(failures: Array[String]) -> void:
	var trex := TREX_BOSS_SCENE.instantiate() as BossBase
	var rift := RIFT_BOSS_SCENE.instantiate() as BossBase
	var wall := BREAKABLE_WALL_SCENE.instantiate() as StaticBody2D

	if trex == null:
		failures.append("T-Rex scene failed to instantiate.")
	else:
		if (trex.collision_mask & 16) == 0:
			failures.append("T-Rex must collide with scripted set-piece layer 16.")
		if trex.display_name != "T-REX":
			failures.append("T-Rex must expose its HUD display name.")

	if rift == null:
		failures.append("Rift Warden scene failed to instantiate.")
	elif rift.display_name != "RIFT WARDEN":
		failures.append("Rift Warden must expose its HUD display name.")

	if wall == null:
		failures.append("Breakable wall scene failed to instantiate.")
	elif wall.collision_layer != 16:
		failures.append("Breakable walls must live exclusively on layer 16.")

	if trex != null:
		trex.free()
	if rift != null:
		rift.free()
	if wall != null:
		wall.free()

func _validate_run_scene_contracts(failures: Array[String]) -> void:
	var run_scene := DUNGEON_RUN_SCENE.instantiate()
	var trex_room := TREX_ROOM_SCENE.instantiate()
	var rift_room := RIFT_ROOM_SCENE.instantiate()

	if run_scene == null:
		failures.append("Dungeon run scene failed to instantiate.")
	else:
		for path in [
			"RoomLayer",
			"PlayerLayer/Player",
			"UI/Status",
			"UI/BossName",
			"UI/BossHealth",
			"UI/Build",
			"UI/Profile",
			"UI/GameOver",
			"UI/Victory",
			"MobileControls",
		]:
			if run_scene.get_node_or_null(path) == null:
				failures.append("Dungeon run missing required node: %s" % path)
		run_scene.free()

	if trex_room == null:
		failures.append("T-Rex runtime room failed to instantiate.")
	else:
		if trex_room.get_node_or_null("TrexBoss") == null:
			failures.append("T-Rex runtime room is missing its boss.")
		trex_room.free()

	var choice_room := CHOICE_ROOM_SCENE.instantiate()
	var pedestal := CHOICE_PEDESTAL_SCENE.instantiate()
	if choice_room == null:
		failures.append("Choice room failed to instantiate.")
	else:
		choice_room.free()
	if pedestal == null:
		failures.append("Choice pedestal failed to instantiate.")
	else:
		pedestal.free()

	if rift_room == null:
		failures.append("Rift runtime room failed to instantiate.")
	else:
		if rift_room.get_node_or_null("ArenaStack/BaseArena/RiftWarden") == null:
			failures.append("Rift runtime room is missing Rift Warden.")
		rift_room.free()
