extends RefCounted

const RoomGraphGeneratorScript := preload("res://scripts/dungeon/room_graph_generator.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var generator := RoomGraphGeneratorScript.new()
	var first: Dictionary = generator.generate(424242, 8, 4)
	var second: Dictionary = generator.generate(424242, 8, 4)

	if first != second:
		failures.append("Same seed must generate the same room graph.")

	var rooms: Array = first["rooms"]
	var boss_count := 0
	for room in rooms:
		if room["kind"] == &"boss":
			boss_count += 1
	if boss_count != 1:
		failures.append("Dungeon graph must contain exactly one boss room.")

	if not _all_rooms_reachable(first):
		failures.append("Every generated room must be reachable from the start.")

	if int(first["boss_id"]) == int(first["start_id"]):
		failures.append("Boss room cannot be the start room.")

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
