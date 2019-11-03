extends "res://BaseClasses/KinematicMotion.gd"

export var sightRange: Vector2 = Vector2(256, 32)
export var WALKSPEED: float = 200

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite
onready var stateMachine = $StateMachine
onready var shape = $CollisionShape2D

var player = null
var updatePhysics: bool = true
var storedBoostVector: Vector2


func _ready():
	add_to_group("enemies")
	player = get_node("/root/World/Player") #attempt to get player

func jumped_on():
	stateMachine.set_current_state("StateStunned")

func boosted_into(boostVector: Vector2, hitPostiion: Vector2):
	stateMachine.set_current_state("StateDying")
	storedBoostVector = boostVector
	shape.set_deferred("disabled", true)
	velocity = storedBoostVector * 5
	print(velocity)

func _physics_process(delta):
	
	velocity.y += delta * GRAVITY
	apply_base_movement(delta, velocity)

func _anim_end(anim : String):
	if anim == "chump_alert":
		stateMachine.set_current_state("StateWalking")
	if anim == "chump_squish_small":
		stateMachine.set_current_state("StateDefault")

func evaluate_sight(pos: Vector2):
	var delta : Vector2 = pos - position
	return player.is_on_floor() and \
		sign(delta.x) == (1 if sprite.flip_h else -1) and \
		abs(delta.x)<=sightRange.x && abs(delta.y)<=sightRange.y

func dir():
	return (1 if sprite.flip_h else -1)

func flip():
	sprite.flip_h = !sprite.flip_h
