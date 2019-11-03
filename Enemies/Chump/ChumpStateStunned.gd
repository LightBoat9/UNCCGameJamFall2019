extends Node

var chump
onready var anim_player = $"../../AnimationPlayer"

func _ready():
	chump = get_owner()

func state_entered() -> void:
	anim_player.stop()
	anim_player.play("chump_squish_small")

func state_exited() -> void:
	anim_player.stop()
