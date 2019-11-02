extends Node

func state_physics_process(delta: float) -> void:
	get_owner().default_movement(delta)
	get_owner().default_collisions()
	get_owner().default_animation(delta)
	
	if Input.is_action_pressed("ui_cancel"):
		get_parent().current_state = "StateBoost"
