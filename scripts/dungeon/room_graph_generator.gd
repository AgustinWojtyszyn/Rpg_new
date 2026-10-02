class_name RoomGraphGenerator
extends RefCounted

const KIND_START := &"start"
const KIND_COMBAT := &"combat"
const KIND_EVENT := &"event"
const KIND_TREASURE := &"treasure"
const KIND_BOSS := &"boss"

func generate(seed_value: int, main_path_rooms: int = 7, side_room_count: int = 3) -> Dictionary:
	main_path_rooms = maxi(main_path_rooms, 4)
	side_room_count = maxi(side_room_count, 0)

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	var rooms: Array[Dictionary] = []
	for index in range(main_path_rooms):
		var kind: StringName = KIND_COMBAT
		if index == 0:
			kind = KIND_START
		elif index == main_path_rooms - 1:
			kind = KIND_BOSS
		else:
			var roll := rng.randf()
			if roll >= 0.84:
				kind = KIND_TREASURE
			elif roll >= 0.72:
				kind = KIND_EVENT
		rooms.append(_make_room(index, kind, index))

	for index in range(main_path_rooms - 1):
		_connect(rooms, index, index + 1)

	for _side in range(side_room_count):
		var parent_id := rng.randi_range(1, main_path_rooms - 2)
		var new_id := rooms.size()
		var side_roll := rng.randf()
		var kind: StringName = KIND_COMBAT
		if side_roll >= 0.70:
			kind = KIND_TREASURE
		elif side_roll >= 0.45:
			kind = KIND_EVENT
		rooms.append(_make_room(new_id, kind, int(rooms[parent_id]["depth"]) + 1))
		_connect(rooms, parent_id, new_id)

	return {
		"seed": seed_value,
		"start_id": 0,
		"boss_id": main_path_rooms - 1,
		"rooms": rooms,
	}

func _make_room(id: int, kind: StringName, depth: int) -> Dictionary:
	return {
		"id": id,
		"kind": kind,
		"depth": depth,
		"connections": [] as Array[int],
	}

func _connect(rooms: Array[Dictionary], a: int, b: int) -> void:
	var a_connections: Array = rooms[a]["connections"]
	var b_connections: Array = rooms[b]["connections"]
	if not a_connections.has(b):
		a_connections.append(b)
	if not b_connections.has(a):
		b_connections.append(a)
