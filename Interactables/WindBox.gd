extends Area2D

export var PUSHFORCE : float = 1200

onready var pushing : Array

func _on_WindBox_body_entered(body):
	if body.is_in_group("pushable"):
		pushing.append(body)

func _on_WindBox_body_exited(body):
	var index: int = pushing.find(body)
	
	if (index>=0):
		pushing.remove(index)

func _physics_process(delta):
	for body in pushing:
		body.apply_external_force(-Vector2.DOWN.rotated(global_rotation) * PUSHFORCE * delta)
