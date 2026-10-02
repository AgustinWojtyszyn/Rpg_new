extends RefCounted

const RoomGraphGeneratorScript := preload("res://scripts/dungeon/room_graph_generator.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var generator := RoomGraphGeneratorScript.new()

	var first: Dictionary = generator.generate(424242, 9, 4)
	var second: Dictionary = generator.generate(424242, 9, 4)
	if first != second:
		failures.append("Same seed must generate the same room graph.")

	for seed_value in range(1, 501):
		var layout: Dictionary = generator.generate(seed_value, 9, 4)
		_validate_layout(layout, failures, seed_value)
		if not failures.is_empty():
			break

	return failures

func _validate_layout(layout: Dictionary, failures: Array[String], seed_value: int) -> void:
	var rooms: Array = layout["rooms"]
	var boss_count := 0
	var miniboss_count := 0
	var treasure_count := 0
	var event_count := 0

	for room in rooms:
		if room["kind"] == &"boss":
			boss_count += 1
		elif room["kind"] == &"miniboss":
			miniboss_count += 1
		elif room["kind"] == &"treasure":
			treasure_count += 1
		elif room["kind"] == &"event":
			event_count += 1

		if room["connections"].size() > 4:
			failures.append("Seed %d: room exposes more than four directional doors." % seed_value)
			return
		if room["doors"].size() != room["connections"].size():
			failures.append("Seed %d: every connection must have one directional door." % seed_value)
			return

	if boss_count != 1:
		failures.append("Seed %d: expected exactly one final boss room." % seed_value)
		return
	if miniboss_count != 1:
		failures.append("Seed %d: expected exactly one miniboss room." % seed_value)
		return
	if treasure_count < 1:
		failures.append("Seed %d: run must guarantee at least one treasure room." % seed_value)
		return
	if event_count < 1:
		failures.append("Seed %d: run must guarantee at least one event room." % seed_value)
		return
	if not _all_rooms_reachable(layout):
		failures.append("Seed %d: generated an unreachable room." % seed_value)
		return
	if int(layout["boss_id"]) == int(layout["start_id"]):
		failures.append("Seed %d: boss room equals start room." % seed_value)
		return
	if int(layout["miniboss_id"]) == int(layout["boss_id"]):
		failures.append("Seed %d: miniboss equals final boss." % seed_value)
		return
	if not _doors_are_reciprocal(rooms):
		failures.append("Seed %d: directional door reciprocity failed." % seed_value)

func _all_rooms_reachable(layout: Dictionary) -> bool:
	var rooms: Array = layout["rooms"]
	var pending: Array[int] = [int(layout["start_id"])]
	var visited: Dictionary = {}

	while not pending.is_empty():
		var current := pending.pop_front()
		if visited.has(current):
			continue
		visited[current] = true
		for neighbor in rooms[current]["connections"]:
			if not visited.has(int(neighbor)):
				pending.append(int(neighbor))

	return visited.size() == rooms.size()

func _doors_are_reciprocal(rooms: Array) -> bool:
	var opposites := {
		&"north": &"south",
		&"south": &"north",
		&"east": &"west",
		&"west": &"east",
	}

	for room in rooms:
		var room_id := int(room["id"])
		var doors: Dictionary = room["doors"]
		for slot in doors:
			var destination := int(doors[slot])
			var opposite: StringName = opposites[slot]
			var destination_doors: Dictionary = rooms[destination]["doors"]
			if not destination_doors.has(opposite):
				return false
			if int(destination_doors[opposite]) != room_id:
				return false
	return true
