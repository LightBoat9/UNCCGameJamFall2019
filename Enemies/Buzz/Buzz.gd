extends "res://BaseClasses/KinematicMotion.gd"

onready var stateMachine = $StateMachine
onready var shape = $CollisionShape2D
onready var anim_player = $AnimationPlayer

var storedBoostVector: Vector2

func _ready():
	add_to_group("enemies")

func _physics_process(delta):
	apply_base_movement(delta, velocity)

func jumped_on():
	stateMachine.set_current_state("StateStunned")

func boosted_into(boostVector: Vector2, hitPostiion: Vector2):
	stateMachine.set_current_state("StateDying")
	shape.set_deferred("disabled", true)
	velocity = boostVector * 5
	storedBoostVector = boostVector


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "buzz_squish":
		stateMachine.set_current_state("StateDefault")
