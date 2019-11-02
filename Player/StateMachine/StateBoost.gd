extends Node

export var BOOST_SPEED = 100

var boost_velocity: Vector2 = Vector2()

func state_entered():
	get_owner().anim_player.play("player_boost_up")
	boost_velocity = (get_owner().dir_input * Vector2.ONE) * BOOST_SPEED

func state_physics_process(delta: float):
	get_owner().apply_base_movement(delta, boost_velocity)
	get_owner().handle_sprite_flip()
