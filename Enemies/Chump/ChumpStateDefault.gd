extends Node

onready var chump = get_owner()
onready var anim_player = $"../../AnimationPlayer"

func state_entered() -> void:
	anim_player.play("chump_idle")

func state_physics_process(delta: float) -> void:
	if chump.evaluate_sight(chump.player.position):
		anim_player.play("chump_alert")
