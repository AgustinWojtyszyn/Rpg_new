class_name RoomDefinition
extends Resource

const KIND_START := &"start"
const KIND_COMBAT := &"combat"
const KIND_EVENT := &"event"
const KIND_TREASURE := &"treasure"
const KIND_BOSS := &"boss"

@export var id: StringName
@export var kind: StringName = KIND_COMBAT
@export var scene: PackedScene
@export_range(0, 100, 1) var min_depth: int = 0
@export_range(0, 100, 1) var max_depth: int = 100
@export_range(0.01, 100.0, 0.01) var weight: float = 1.0
@export var tags: PackedStringArray = PackedStringArray()

func supports_depth(depth: int) -> bool:
	return depth >= min_depth and depth <= max_depth
