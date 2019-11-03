extends Node

var chump
onready var timer: Timer = $Timer
onready var anim_player = $"../../AnimationPlayer"

func _ready():
	chump = get_owner()

func state_exited() -> void:
	anim_player.seek(0, true)
	timer.start()

func state_entered() -> void:
	anim_player.play("chump_dying")
	var angle: float = get_owner().storedBoostVector.angle()
