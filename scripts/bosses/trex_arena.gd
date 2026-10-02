extends Node2D

@onready var player: PlayerCharacter = $Actors/Player
@onready var boss: BossBase = $Actors/TrexBoss
@onready var status_label: Label = $UI/Status

func _ready() -> void:
	boss.configure_target(player)
	boss.phase_changed.connect(_on_phase_changed)
	boss.boss_died.connect(_on_boss_died)
	queue_redraw()

func _process(_delta: float) -> void:
	if is_instance_valid(boss):
		status_label.text = "T-REX  HP %d / %d   ·   Fase %d\nE cerca de una palanca · B vuelve al laboratorio" % [
			roundi(boss.health.current_health),
			roundi(boss.health.max_health),
			boss.phase_model.current_phase + 1,
		]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_B:
			get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _on_phase_changed(phase: int) -> void:
	status_label.text = "T-REX entra en fase %d · una carga especial quedó disponible" % (phase + 1)

func _on_boss_died() -> void:
	status_label.text = "T-REX DERROTADO · sin fases de inmunidad · B vuelve"

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color(0.075, 0.065, 0.055), true)
	for x in range(0, 961, 64):
		draw_line(Vector2(x, 0), Vector2(x, 540), Color(0.12, 0.10, 0.08), 1.0)
	for y in range(0, 541, 64):
		draw_line(Vector2(0, y), Vector2(960, y), Color(0.12, 0.10, 0.08), 1.0)
	draw_rect(Rect2(24, 38, 912, 474), Color(0.48, 0.32, 0.18), false, 3.0)
