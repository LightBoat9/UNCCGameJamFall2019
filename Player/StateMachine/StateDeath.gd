extends Node

func state_entered():
	get_owner().anim_player.play("player_death")
