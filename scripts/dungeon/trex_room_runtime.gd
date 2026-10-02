class_name TrexRoomRuntime
extends RoomBase

signal miniboss_defeated

@onready var boss: BossBase = $TrexBoss

func setup(data: Dictionary, run_player: PlayerCharacter, already_cleared: bool) -> void:
	setup_base(data, run_player, already_cleared)

	if already_cleared:
		$TrexBoss.queue_free()
		$Mechanics.queue_free()
		return

	boss.configure_target(player)
	boss.boss_died.connect(_on_boss_died)

func get_boss() -> BossBase:
	return boss if is_instance_valid(boss) and not boss.is_queued_for_deletion() else null

func _on_boss_died() -> void:
	mark_cleared()
	miniboss_defeated.emit()
