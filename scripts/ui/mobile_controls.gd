class_name MobileControls
extends CanvasLayer

@export var force_visible_in_editor: bool = false

@onready var root: Control = $Root
@onready var joystick: VirtualJoystick = $Root/MoveJoystick
@onready var attack: TouchScreenButton = $Root/Attack
@onready var dash: TouchScreenButton = $Root/Dash
@onready var interact: TouchScreenButton = $Root/Interact
@onready var restart: TouchScreenButton = $Root/Restart

func _ready() -> void:
	root.visible = force_visible_in_editor or DisplayServer.is_touchscreen_available()
	show_gameplay()

func show_gameplay() -> void:
	joystick.visible = true
	attack.visible = true
	dash.visible = true
	interact.visible = true
	restart.visible = false

func show_end_state() -> void:
	joystick.visible = false
	attack.visible = false
	dash.visible = false
	interact.visible = false
	restart.visible = true
