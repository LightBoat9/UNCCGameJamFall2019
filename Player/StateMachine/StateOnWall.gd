extends Node

export var WALL_GRAVITY: float = 400
export var MAXDOWNSPEED: float = 256

func state_entered() -> void:
	get_owner().rays_setEnable(true)
	get_owner().anim_player.play("player_on_wall")
	get_owner().velocity.x = 0
	
func state_exited() -> void:
	get_owner().rays_setEnable(false)
	pass

func state_physics_process(delta: float) -> void:
	get_owner().gravity_tick_custom(WALL_GRAVITY, delta)
	get_owner().vertical_clamp(MAXDOWNSPEED)
	get_owner().apply_velocity()
	
	#exit conditions
	if get_owner().hanging_off_wall() or \
		(get_owner().input_dir.x>0 and get_owner().sprite.flip_h) or (get_owner().input_dir.x<0 and not get_owner().sprite.flip_h):
		get_parent().current_state = "StateDefault"
	elif get_owner().input_jumpPressed:
		get_owner().jump(true)
		get_parent().current_state = "StateDefault"
	
	get_owner().rays_updateFacing()
