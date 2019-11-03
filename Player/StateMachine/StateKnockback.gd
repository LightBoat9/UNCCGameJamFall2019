extends Node

const X_LIMIT = 10

func state_entered():
	get_owner().anim_player.stop()
	get_owner().sprite.frame = 0
	get_owner().sprite.modulate = Color.red
	
func state_exited():
	get_owner().sprite.modulate = Color.white
	
func state_physics_process(delta: float):
	get_owner().apply_base_movement(delta, Vector2())

	if abs(get_owner().velocity.x) < X_LIMIT:
		get_parent().current_state = "StateDefault"
