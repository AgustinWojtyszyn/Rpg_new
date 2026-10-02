class_name ArenaStack
extends Node2D

signal arena_pushed(arena: Node2D)
signal arena_popped(arena: Node2D)

const SUSPEND_OFFSET := Vector2(10000.0, 10000.0)

var active_arena: Node2D
var _suspended: Array[Dictionary] = []

func register_base_arena(arena: Node2D) -> void:
	active_arena = arena

func push_scene(scene: PackedScene) -> Node2D:
	if scene == null:
		return null

	if active_arena != null:
		_suspended.append({
			"arena": active_arena,
			"position": active_arena.position,
			"process_mode": active_arena.process_mode,
			"visible": active_arena.visible,
		})
		active_arena.process_mode = Node.PROCESS_MODE_DISABLED
		active_arena.visible = false
		active_arena.position += SUSPEND_OFFSET

	var instance := scene.instantiate() as Node2D
	if instance == null:
		_restore_previous()
		return null

	add_child(instance)
	active_arena = instance
	arena_pushed.emit(instance)
	return instance

func pop_arena() -> Node2D:
	if active_arena != null:
		var leaving := active_arena
		active_arena = null
		leaving.process_mode = Node.PROCESS_MODE_DISABLED
		leaving.visible = false
		leaving.position += SUSPEND_OFFSET
		leaving.queue_free()

	var restored := _restore_previous()
	if restored != null:
		arena_popped.emit(restored)
	return restored

func has_suspended_arena() -> bool:
	return not _suspended.is_empty()

func _restore_previous() -> Node2D:
	if _suspended.is_empty():
		return null
	var snapshot: Dictionary = _suspended.pop_back()
	var arena := snapshot["arena"] as Node2D
	if not is_instance_valid(arena):
		return null
	arena.position = snapshot["position"]
	arena.process_mode = int(snapshot["process_mode"])
	arena.visible = bool(snapshot["visible"])
	active_arena = arena
	return arena
