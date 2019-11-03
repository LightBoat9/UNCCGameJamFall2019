extends KinematicBody2D

export var GRAVITY: float = 800
export var ACCELERATION: float = 1024
export var DECELERATION: float = 800
export var MAX_Y_SPEED: float = 500

var velocity: Vector2 = Vector2()

func apply_base_movement(delta: float, vector: Vector2) -> void:
	velocity += vector * delta
	
	velocity.y += delta * GRAVITY
	
	var delta_x = -velocity.x
	var max_displacement = DECELERATION * delta
	velocity.x += clamp(delta_x, -max_displacement, max_displacement)
	
	velocity.y = min(velocity.y, MAX_Y_SPEED)
	
	velocity = move_and_slide(velocity, Vector2.UP)
