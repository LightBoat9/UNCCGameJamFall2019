extends Node

var chump
var impactVector: Vector2

func _ready():
	chump = get_owner()

func state_entered() -> void:
	chump.anim_player.play("chump_dying")

func init(var impactDirection: Vector2):
	impactVector = impactDirection
	
	if (impactDirection.angle()>=(PI/4) && impactDirection.angle()<=(3*PI)/4):
		print("squish")
	
	
	pass
