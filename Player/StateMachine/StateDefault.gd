extends Node

func state_physics_process(delta: float) -> void:
	get_owner().default_movement(delta)
	get_owner().default_collisions()
	get_owner().default_animation(delta)
	
	if get_owner().ready_to_boost() and Input.is_action_just_pressed("ui_cancel"):
		get_parent().current_state = "StateBoost"
		get_owner().jumped = false
