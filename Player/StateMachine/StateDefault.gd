extends Node

export var PUSHDOWN: float = 20
export var WALKSPEED: float = 256
export var GROUNDACCEL: float = 1024
export var GROUNDDECEL: float = 800

onready var jump = $"../StateAirborne"

func state_entered():
	get_owner().can_boost = true

func state_physics_process(delta: float) -> void:
	#input & velocity
	if (get_owner().velocity.y >= 0):
		get_owner().velocity.y = PUSHDOWN
	
	get_owner().accelerate_horizontal(WALKSPEED,GROUNDACCEL,GROUNDDECEL,delta)
	get_owner().apply_velocity()
	
	get_owner().default_collisions()
	get_owner().handle_sprite_flip()
	
	#state transitions
	if !get_owner().is_on_floor():
		get_parent().current_state = "StateAirborne"
	elif get_owner().input_jumpPressed:
		get_owner().jump_grace.start()
		get_owner().jump()
		jump.jumped = true
		get_parent().current_state = "StateAirborne"
	elif !get_owner().boost_check():
		anim_update()

func anim_update() -> void:
	if get_owner().velocity.x == 0:
		get_owner().anim_player.play("player_idle")
	elif sign(get_owner().velocity.x) != sign(get_owner().input_dir.x) and sign(get_owner().input_dir.x) != 0:
		get_owner().anim_player.play("player_turn_around")
	else:
		get_owner().anim_player.play("player_run", -1, get_owner().velocity.x/get_owner().MAX_X_SPEED)
