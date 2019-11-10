extends KinematicBody2D

export var GRAVITY: float = 800
export var ACCELERATION: float = 1024
export var DECELERATION: float = 800
export var MAX_Y_SPEED: float = 500

var velocity: Vector2 = Vector2()
var externalForce: Vector2 = Vector2()

func apply_base_movement(delta: float, vector: Vector2, apply_gravity=true) -> void:
	velocity += vector * delta
	
	if apply_gravity:
		velocity.y += delta * GRAVITY
	
	var delta_x = -velocity.x
	var max_displacement = DECELERATION * delta
	velocity.x += clamp(delta_x, -max_displacement, max_displacement)
	
	velocity.y = min(velocity.y, MAX_Y_SPEED)
	
	velocity = move_and_slide(velocity, Vector2.UP)

#to be called within a physics update
func apply_velocity(use_external: bool = true):
	if use_external:
		velocity += externalForce
	externalForce = Vector2()
	
	velocity = move_and_slide(velocity, Vector2.UP)

#instant change to velocity, etc
func apply_force(force: Vector2):
	velocity += force

#external force applied independently from velocity (resets on movement)
func apply_external_force(force: Vector2):
	externalForce += force

static func accelerate(currentSpeed: float, targetSpeed: float, acceleration: float, deceleration: float):
	var delta_x: float = targetSpeed - currentSpeed
	var max_displacement: float = (acceleration if (sign(delta_x)==sign(currentSpeed) or sign(currentSpeed)==0) else deceleration)
	return currentSpeed + clamp(delta_x, -max_displacement, max_displacement)
