extends Node

var chump

func _ready():
	chump = get_owner()

func state_entered() -> void:
	chump.anim_player.stop()
	chump.anim_player.play("chump_squish_small")

func state_exited() -> void:
	chump.anim_player.stop()
