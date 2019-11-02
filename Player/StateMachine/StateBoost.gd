extends Node

export var BOOST_SPEED = 600

onready var timer = $Timer

func state_entered():
	get_owner().can_boost = false
	get_owner().anim_player.play("player_boost_up")
	get_owner().velocity = (get_owner().dir_input * Vector2.ONE) * BOOST_SPEED
	timer.start()

func state_physics_process(delta: float):
	get_owner().apply_base_movement(delta, Vector2())
	get_owner().handle_sprite_flip()
	
	if get_owner().is_on_ceiling() or get_owner().is_on_floor() or get_owner().is_on_wall():
		timer.stop()
		_on_Timer_timeout()

func _on_Timer_timeout():
	get_parent().current_state = "StateDefault"
