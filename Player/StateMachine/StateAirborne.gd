extends Node

export var MAXAIRSPEED: float = 256
export var AIRACCEL: float = 1024
export var AIRDECEL: float = 800



#set this to true if you want this particular state iteration 
#to handle variable jump height
var jumped : bool = false

func state_entered()->void:
	get_owner().rays_setEnable(true)

func state_exited()->void:
	get_owner().rays_setEnable(false)
	jumped = false

func state_physics_process(delta: float ) -> void:
	#input & velocity
	get_owner().gravity_tick(delta)
	get_owner().vertical_clamp()
	
	if jumped:
		if get_owner().velocity.y < 0:
			if !get_owner().input_jump:
				get_owner().velocity.y *= get_owner().JUMP_DROP_MULTIPLIER
		else:
			jumped = false
	
	get_owner().accelerate_horizontal(MAXAIRSPEED,AIRACCEL,AIRDECEL,delta)
	get_owner().apply_velocity()
	get_owner().handle_sprite_flip()
	
	#state tranitions
	if get_owner().is_on_floor():
		get_parent().current_state = "StateDefault"
	elif get_owner().can_wall_jump():
		get_parent().current_state = "StateOnWall"
	elif !get_owner().boost_check():
		anim_update()
	
	get_owner().rays_updateFacing()

func anim_update() -> void:
	if get_owner().velocity.y > 0:
		get_owner().anim_player.play("player_air_down")
	else:
		get_owner().anim_player.play("player_air_up")
