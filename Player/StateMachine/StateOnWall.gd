extends Node

export var WALL_GRAVITY: float = 100

func state_entered() -> void:
	get_owner().anim_player.play("player_on_wall")
	get_owner().velocity.x = 0
	
func state_exited() -> void:
	#get_owner().jump_grace.start()
	pass
	
func state_physics_process(delta: float) -> void:
	if get_owner().velocity.y > 0:
		get_owner().apply_base_movement(delta, Vector2(0, WALL_GRAVITY))
	else:
		get_owner().apply_base_movement(delta, Vector2(0, get_owner().GRAVITY))
		
	if get_owner().hanging_off_wall():
		get_parent().current_state = "StateDefault"
	elif Input.is_action_just_pressed("ui_select"):
		get_owner().jump(true)
		get_parent().current_state = "StateDefault"
	elif Input.is_action_pressed("ui_right") and get_owner().sprite.flip_h:
		get_parent().current_state = "StateDefault"
		
	elif Input.is_action_pressed("ui_left") and not get_owner().sprite.flip_h:
		get_parent().current_state = "StateDefault"
		
