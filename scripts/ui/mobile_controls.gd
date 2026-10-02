extends CanvasLayer

@export var force_visible_in_editor: bool = false

func _ready() -> void:
	$Root.visible = force_visible_in_editor or DisplayServer.is_touchscreen_available()
