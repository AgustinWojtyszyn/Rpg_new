extends SceneTree

const TEST_SCRIPTS := [
	preload("res://tests/test_health_component.gd"),
	preload("res://tests/test_room_graph.gd"),
	preload("res://tests/test_encounter_director.gd"),
	preload("res://tests/test_run_rng.gd"),
	preload("res://tests/test_room_selector.gd"),
	preload("res://tests/test_boss_phase_model.gd"),
	preload("res://tests/test_scene_contracts.gd"),
	preload("res://tests/test_run_build.gd"),
	preload("res://tests/test_reward_director.gd"),
	preload("res://tests/test_progression.gd"),
]

func _init() -> void:
	var failures: Array[String] = []
	print("TEST HARNESS START · %d suites" % TEST_SCRIPTS.size())

	for test_script in TEST_SCRIPTS:
		print("RUNNING SUITE · %s" % test_script.resource_path)
		var test_case = test_script.new()
		var case_failures: Array[String] = test_case.run()
		for failure in case_failures:
			failures.append("%s: %s" % [test_script.resource_path, failure])
		print("FINISHED SUITE · %s · %d failure(s)" % [
			test_script.resource_path,
			case_failures.size(),
		])

	if failures.is_empty():
		print("ALL TESTS PASSED (%d suites)" % TEST_SCRIPTS.size())
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	print("TESTS FAILED: %d failure(s)" % failures.size())
	quit(1)
