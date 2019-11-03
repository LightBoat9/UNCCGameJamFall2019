extends Node

var chump

func _ready():
	chump = get_owner()

func state_exited() -> void:
	chump.anim_player.seek(0, true)

func state_entered() -> void:
	chump.anim_player.play("chump_dying")
	var angle: float = get_owner().storedBoostVector.angle()
	print(angle)
	
	if (get_owner().storedBoostVector.angle()>=(PI/4) && get_owner().storedBoostVector.angle()<=(3*PI)/4):
		print("squish")
