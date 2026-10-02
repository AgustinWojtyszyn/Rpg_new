extends RefCounted

const RoomGraphGeneratorScript := preload("res://scripts/dungeon/room_graph_generator.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var generator := RoomGraphGeneratorScript.new()
	var first: Dictionary = generator.generate(424242, 9, 4)
	var second: Dictionary = generator.generate(424242, 9, 4)

	if first != second:
		failures.append("Same seed must generate the same room graph.")

	var rooms: Array = first["rooms"]
	var boss_count := 0
	var miniboss_count := 0
	for room in rooms:
		if room["kind"] == &"boss":
			boss_count += 1
		elif room["kind"] == &"miniboss":
			miniboss_count += 1

		if room["connections"].size() > 4:
			failures.append("A room cannot expose more than four directional doors.")
		if room["doors"].size() != room["connections"].size():
			failures.append("Every connection must have exactly one directional door.")

	if boss_count != 1:
		failures.append("Dungeon graph must contain exactly one final boss room.")
	if miniboss_count != 1:
		failures.append("Dungeon graph must contain exactly one miniboss room.")
	if not _all_rooms_reachable(first):
		failures.append("Every generated room must be reachable from the start.")
	if int(first["boss_id"]) == int(first["start_id"]):
		failures.append("Boss room cannot be the start room.")
	if int(first["miniboss_id"]) == int(first["boss_id"]):
		failures.append("Miniboss and final boss must be different rooms.")
	if not _doors_are_reciprocal(rooms):
		failures.append("Directional doors must have reciprocal destinations.")

	return failures

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
