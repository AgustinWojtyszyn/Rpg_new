extends RefCounted

const RunRngScript := preload("res://scripts/core/run_rng.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var first := RunRngScript.new(123456)
	var second := RunRngScript.new(123456)

	var first_layout: RandomNumberGenerator = first.make_stream(RunRngScript.Stream.LAYOUT)
	var second_layout: RandomNumberGenerator = second.make_stream(RunRngScript.Stream.LAYOUT)
	for _index in range(8):
		if first_layout.randi() != second_layout.randi():
			failures.append("Same root seed and stream must produce the same sequence.")
			break

	var layout: RandomNumberGenerator = first.make_stream(RunRngScript.Stream.LAYOUT)
	var loot: RandomNumberGenerator = first.make_stream(RunRngScript.Stream.LOOT)
	var identical := true
	for _index in range(4):
		if layout.randi() != loot.randi():
			identical = false
			break
	if identical:
		failures.append("Independent RNG streams should not share the same sequence.")

	return failures
