extends RefCounted

const HealthComponentScript := preload("res://scripts/components/health_component.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var health := HealthComponentScript.new()
	health.configure(100.0)

	if health.apply_damage(30.0) != 30.0:
		failures.append("Health should apply requested damage.")
	if not is_equal_approx(health.current_health, 70.0):
		failures.append("Health should be 70 after 30 damage.")
	if health.apply_damage(500.0) != 70.0:
		failures.append("Overkill should report only remaining health.")
	if not health.is_dead():
		failures.append("Health should report dead at zero.")

	health.reset()
	if not is_equal_approx(health.current_health, 100.0):
		failures.append("Reset should refill to max health.")

	return failures
