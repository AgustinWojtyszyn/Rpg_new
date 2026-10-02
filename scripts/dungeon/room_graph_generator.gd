class_name RoomGraphGenerator
extends RefCounted

const KIND_START := &"start"
const KIND_COMBAT := &"combat"
const KIND_EVENT := &"event"
const KIND_TREASURE := &"treasure"
const KIND_MINIBOSS := &"miniboss"
const KIND_BOSS := &"boss"

const SLOT_NORTH := &"north"
const SLOT_SOUTH := &"south"
const SLOT_EAST := &"east"
const SLOT_WEST := &"west"

func generate(seed_value: int, main_path_rooms: int = 9, side_room_count: int = 4) -> Dictionary:
	main_path_rooms = maxi(main_path_rooms, 7)
	side_room_count = maxi(side_room_count, 0)

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	var rooms: Array[Dictionary] = []
	var miniboss_index := main_path_rooms - 3

	for index in range(main_path_rooms):
		var kind: StringName = KIND_COMBAT
		if index == 0:
			kind = KIND_START
		elif index == miniboss_index:
			kind = KIND_MINIBOSS
		elif index == main_path_rooms - 1:
			kind = KIND_BOSS
		else:
			var roll := rng.randf()
			if roll >= 0.86:
				kind = KIND_TREASURE
			elif roll >= 0.74:
				kind = KIND_EVENT
		rooms.append(_make_room(index, kind, index))

	_guarantee_choice_rooms(rooms, miniboss_index, rng)

	for index in range(main_path_rooms - 1):
		_connect(rooms, index, index + 1, SLOT_EAST, SLOT_WEST)

	for _side in range(side_room_count):
		var parent_candidates: Array[int] = []
		for parent_id in range(1, main_path_rooms - 1):
			var parent: Dictionary = rooms[parent_id]
			if parent["kind"] == KIND_MINIBOSS:
				continue
			var doors: Dictionary = parent["doors"]
			if not doors.has(SLOT_NORTH) or not doors.has(SLOT_SOUTH):
				parent_candidates.append(parent_id)

		if parent_candidates.is_empty():
			break

		var parent_id := parent_candidates[rng.randi_range(0, parent_candidates.size() - 1)]
		var parent_doors: Dictionary = rooms[parent_id]["doors"]
		var available_slots: Array[StringName] = []
		if not parent_doors.has(SLOT_NORTH):
			available_slots.append(SLOT_NORTH)
		if not parent_doors.has(SLOT_SOUTH):
			available_slots.append(SLOT_SOUTH)

		var parent_slot := available_slots[rng.randi_range(0, available_slots.size() - 1)]
		var side_slot := SLOT_SOUTH if parent_slot == SLOT_NORTH else SLOT_NORTH
		var new_id := rooms.size()
		var side_roll := rng.randf()
		var kind: StringName = KIND_COMBAT
		if side_roll >= 0.70:
			kind = KIND_TREASURE
		elif side_roll >= 0.44:
			kind = KIND_EVENT

		rooms.append(_make_room(new_id, kind, int(rooms[parent_id]["depth"]) + 1))
		_connect(rooms, parent_id, new_id, parent_slot, side_slot)

	return {
		"seed": seed_value,
		"start_id": 0,
		"miniboss_id": miniboss_index,
		"boss_id": main_path_rooms - 1,
		"rooms": rooms,
	}

func _guarantee_choice_rooms(
	rooms: Array[Dictionary],
	miniboss_index: int,
	rng: RandomNumberGenerator
) -> void:
	var eligible: Array[int] = []
	for index in range(1, rooms.size() - 1):
		if index != miniboss_index:
			eligible.append(index)

	if eligible.size() < 2:
		return

	if _count_kind(rooms, eligible, KIND_TREASURE) == 0:
		var candidates := _ids_with_kind(rooms, eligible, KIND_COMBAT)
		if candidates.is_empty():
			candidates = _ids_with_kind(rooms, eligible, KIND_EVENT)
		var target := candidates[rng.randi_range(0, candidates.size() - 1)]
		rooms[target]["kind"] = KIND_TREASURE

	if _count_kind(rooms, eligible, KIND_EVENT) == 0:
		var candidates := _ids_with_kind(rooms, eligible, KIND_COMBAT)
		if candidates.is_empty():
			candidates = _ids_with_kind(rooms, eligible, KIND_TREASURE)
		# Keep at least one treasure when converting from an all-treasure layout.
		if candidates.size() > 1:
			var target := candidates[rng.randi_range(0, candidates.size() - 1)]
			rooms[target]["kind"] = KIND_EVENT

func _count_kind(
	rooms: Array[Dictionary],
	ids: Array[int],
	kind: StringName
) -> int:
	var count := 0
	for room_id in ids:
		if rooms[room_id]["kind"] == kind:
			count += 1
	return count

func _ids_with_kind(
	rooms: Array[Dictionary],
	ids: Array[int],
	kind: StringName
) -> Array[int]:
	var result: Array[int] = []
	for room_id in ids:
		if rooms[room_id]["kind"] == kind:
			result.append(room_id)
	return result

func _make_room(id: int, kind: StringName, depth: int) -> Dictionary:
	var connections: Array[int] = []
	var doors: Dictionary = {}
	return {
		"id": id,
		"kind": kind,
		"depth": depth,
		"connections": connections,
		"doors": doors,
	}

func _connect(
	rooms: Array[Dictionary],
	a: int,
	b: int,
	a_slot: StringName,
	b_slot: StringName
) -> void:
	var a_connections: Array = rooms[a]["connections"]
	var b_connections: Array = rooms[b]["connections"]
	var a_doors: Dictionary = rooms[a]["doors"]
	var b_doors: Dictionary = rooms[b]["doors"]

	if not a_connections.has(b):
		a_connections.append(b)
	if not b_connections.has(a):
		b_connections.append(a)
	a_doors[a_slot] = b
	b_doors[b_slot] = a
