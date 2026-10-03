extends Control

@onready var controls_panel: Panel = $ControlsPanel
@onready var play_button: Button = $MenuPanel/VBox/Play

func _ready() -> void:
	play_button.grab_focus()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/dungeon/dungeon_run.tscn")

func _on_new_run_pressed() -> void:
	RunSaveStore.clear()
	get_tree().change_scene_to_file("res://scenes/dungeon/dungeon_run.tscn")

func _on_controls_pressed() -> void:
	controls_panel.visible = true
	$ControlsPanel/Close.grab_focus()

func _on_close_controls_pressed() -> void:
	controls_panel.visible = false
	play_button.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if controls_panel.visible and event.is_action_pressed("ui_cancel"):
		_on_close_controls_pressed()
		get_viewport().set_input_as_handled()
