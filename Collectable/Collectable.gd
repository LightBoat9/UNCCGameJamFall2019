extends Area2D

func _on_Collectable_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		$AnimationPlayer.play("free")
		
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "free":
		queue_free()
