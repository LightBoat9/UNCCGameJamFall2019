extends Node

var chump

func _ready():
	chump = get_owner()

func state_entered() -> void:
	chump.anim_player.play("chump_idle")

func state_physics_process(delta: float) -> void:
	if chump.evaluate_sight(chump.player.position):
		chump.anim_player.play("chump_alert")
