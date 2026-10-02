extends RefCounted

const BossPhaseModelScript := preload("res://scripts/bosses/boss_phase_model.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var model := BossPhaseModelScript.new(PackedFloat32Array([0.70, 0.35]))

	if model.update(1.0) != 0:
		failures.append("Boss should start in phase zero.")
	if model.update(0.69) != 1:
		failures.append("Crossing 70 percent should advance the boss phase.")
	if model.update(0.34) != 2:
		failures.append("Crossing 35 percent should advance the boss phase again.")
	if model.update(0.90) != 2:
		failures.append("Boss phases must never move backwards when health observations increase.")

	return failures
