class_name RunRng
extends RefCounted

enum Stream {
	LAYOUT,
	ENCOUNTERS,
	LOOT,
	COSMETICS,
}

const STREAM_SALTS: Array[int] = [
	104729,
	130363,
	155921,
	196613,
]

var root_seed: int

func _init(seed_value: int = 1) -> void:
	root_seed = seed_value if seed_value != 0 else 1

func make_stream(stream: Stream) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = root_seed ^ STREAM_SALTS[int(stream)]
	return rng
