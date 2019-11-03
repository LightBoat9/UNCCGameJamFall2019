extends Node

var buzz
onready var anim_player = $"../../AnimationPlayer"

func _ready():
	buzz = get_owner()

func state_entered() -> void:
	anim_player.play("buzz_idle")
