extends Node

export var BOOST_SPEED = 800
export var BOOST_BOUNCE = 800

onready var timer = $Timer

const boost_anims = ["player_boost_up", "player_boost_up_diag", "player_boost_right", "player_boost_down_diag", "player_boost_down"]

func state_entered():
	get_owner().can_boost = false
	var vec = get_owner().dir_input
	vec.x = abs(vec.x)
	var ind = round(((vec.angle() + (PI/2))/PI)* (len(boost_anims)-1))
	
	get_owner().anim_player.play(boost_anims[ind])
	get_owner().velocity = (get_owner().dir_input.normalized()) * BOOST_SPEED
	get_owner().handle_sprite_flip()
	timer.start()
	
	get_owner().boost_hitbox.monitoring = true
	get_owner().boost_hitbox.position = Vector2(32, 32) * get_owner().dir_input

func state_exited():
	get_owner().boost_hitbox.monitoring = false

func state_physics_process(delta: float):
	get_owner().apply_base_movement(delta, Vector2())
	get_owner().handle_sprite_flip()
	
	for i in range(get_owner().get_slide_count()):
		var col = get_owner().get_slide_collision(i)
		if col.collider.is_in_group("bounce"):
			get_owner().velocity.y = -BOOST_BOUNCE
			get_parent().current_state = "StateDefault"
			get_owner().can_boost = true
			get_owner().hit_stop()
			return
	
	if get_owner().is_on_ceiling() or get_owner().is_on_wall():
		timer.stop()
		_on_Timer_timeout()

func _on_Timer_timeout():
	get_parent().current_state = "StateDefault"
