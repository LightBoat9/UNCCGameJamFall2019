extends Node

export var BOOST_SPEED = 800

onready var timer = $Timer

const boost_anims = ["player_boost_up", "player_boost_up_diag", "player_boost_right", "player_boost_down_diag", "player_boost_down"]

func state_entered():
	get_owner().can_boost = false
	var vec = get_owner().input_dir
	vec.x = abs(vec.x)
	var ind = round(((vec.angle() + (PI/2))/PI)* (len(boost_anims)-1))
	
	get_owner().anim_player.play(boost_anims[ind])
	get_owner().velocity = (get_owner().input_dir.normalized()) * BOOST_SPEED
	get_owner().handle_sprite_flip()
	timer.start()
	
	get_owner().boost_hitbox.monitoring = true
	get_owner().boost_hitbox.position = get_owner().boost_hitbox.get_child(0).shape.extents * get_owner().input_dir

func state_exited():
	get_owner().boost_hitbox.set_deferred("monitoring", false)

func state_physics_process(delta: float):
	get_owner().apply_velocity(false) #don't use external forces
	get_owner().handle_sprite_flip()
	
	if get_owner().is_on_ceiling() or get_owner().is_on_wall():
		timer.stop()
		_on_Timer_timeout()

func _on_Timer_timeout():
	get_parent().current_state = "StateAirborne"
