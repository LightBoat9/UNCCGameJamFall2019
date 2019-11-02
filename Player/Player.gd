extends KinematicBody2D

const GRAVITY = 400
const ACCELERATION = 200
const DECELERATION = 200
const MAX_X_SPEED = 64

var velocity: Vector2 = Vector2()

onready var sprite: Sprite = $Sprite
onready var anim_player: AnimationPlayer = $AnimationPlayer

func default_movement(delta: float) -> void:
	velocity.y += delta * GRAVITY
	
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	velocity.x += x_input * delta * ACCELERATION
	
	if abs(velocity.x) > MAX_X_SPEED or not x_input:
		if abs(velocity.x) > DECELERATION * delta:
			velocity.x -= sign(velocity.x) * delta * DECELERATION
		else:
			velocity.x = 0
		
	move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		velocity.y = 0
		
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
		
func default_animation(delta: float) -> void:
	if velocity.x == 0:
		anim_player.stop()
		sprite.frame = 0
	else:
		anim_player.play("walk")
