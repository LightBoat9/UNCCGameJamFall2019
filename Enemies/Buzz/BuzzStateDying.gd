extends Node

var buzz
onready var timer: Timer = $Timer
onready var anim_player = $"../../AnimationPlayer"

func _ready():
	buzz = get_owner()

func state_exited() -> void:
	buzz.anim_player.seek(0, true)
	timer.start()

func state_entered() -> void:
	anim_player.play("buzz_dying")
	var angle: float = get_owner().storedBoostVector.angle()
	print(angle)
	
	if (get_owner().storedBoostVector.angle()>=(PI/4) && get_owner().storedBoostVector.angle()<=(3*PI)/4):
		print("squish")
