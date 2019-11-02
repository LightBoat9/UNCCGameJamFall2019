extends KinematicBody2D

export var INIT_GRAVITY: float = 20
export var GRAVITY: float = 800
export var ACCELERATION: float = 600
export var DECELERATION: float = 400
export var MAX_X_SPEED: float = 64*3
export var MAX_Y_SPEED: float = 64*3
export var JUMP_SPEED: float = 400
export var WALL_JUMP_SPEED: Vector2 = Vector2(400, -400)
export var WALL_SNAP_DIST: float = 16

var velocity: Vector2 = Vector2()

onready var sprite: Sprite = $Sprite
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var state_machine: Node = $StateMachine
onready var jump_grace: Timer = $JumpGrace

var prev_on_floor = false
var x_input = 0

func default_movement(delta: float) -> void:
	# Start the gravity with some speed so that collision with floor is always detected
	if velocity.y == 0:
		velocity.y = INIT_GRAVITY
	
	velocity.y += delta * GRAVITY
	
	x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if abs(velocity.x) < MAX_X_SPEED:
		velocity.x += x_input * delta * ACCELERATION
	
	if abs(velocity.x) > MAX_X_SPEED or not x_input:
		if abs(velocity.x) > DECELERATION * delta:
			velocity.x -= sign(velocity.x) * delta * DECELERATION
		else:
			velocity.x = 0
		
	var scaled_velocity = move_and_slide(velocity, Vector2.UP)
	
	velocity.y = scaled_velocity.y
	
	# Start grace timer if leaving floor
	if not is_on_floor() and prev_on_floor:
		jump_grace.start()
		
	prev_on_floor = is_on_floor()
	
	if is_on_floor() or (jump_grace.time_left != 0 and velocity.y >= 0):
		if Input.is_action_just_pressed("ui_select"):
			jump()
	
	if not is_on_floor() and is_on_wall():
		if velocity.y > 0:
			velocity.x = 0
			state_machine.set_deferred("current_state", "StateOnWall")
		
	if velocity.x != 0:
		sprite.offset.x = sign(velocity.x) * 16
		sprite.flip_h = velocity.x < 0
		
	if velocity.y>0 && get_slide_count() == 0:
		var snap = Vector2(WALL_SNAP_DIST, 0) * (-1 if sprite.flip_h else 1)
		#	Vector2(sign(velocity.x), 1)
			
		if test_move(transform, snap):
			if Input.is_action_just_pressed("ui_select"):
				# Not multiplied by delta because this is the real distance to move
				move_and_collide(snap)
				#state_machine.set_deferred("current_state", "StateOnWall")
				jump(true)
		
func default_animation(delta: float) -> void:
	if velocity.y == 0:
		if velocity.x == 0:
			anim_player.play("player_idle")
		elif sign(velocity.x) != sign(x_input) && sign(x_input) != 0:
			anim_player.play("player_turnAround")
		else:
			anim_player.play("player_run", -1, velocity.x/MAX_X_SPEED)
	else:
		if velocity.y > 0:
			anim_player.play("player_air_down")
		else:
			anim_player.play("player_air_up")
			
func default_collisions() -> void:
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			if get_slide_collision(i).collider.is_in_group("enemies"):
				jump()

func jump(off_wall = false) -> void:
	jump_grace.stop()
	
	if off_wall:
		velocity = WALL_JUMP_SPEED * Vector2((1 if $Sprite.flip_h else -1), 1)
	else:
		velocity.y = -JUMP_SPEED
