extends "res://BaseClasses/KinematicMotion.gd"

export var INIT_GRAVITY: float = 20
export var MAX_X_SPEED: float = 256
export var JUMP_SPEED: float = 400
export var BOUNCE_JUMP_SPEED: float = 500
export var JUMP_DROP_MULTIPLIER: float = 0.8
export var WALL_JUMP_SPEED: Vector2 = Vector2(600, -400)
export var WALL_SNAP_DIST: float = 16
export var BOOST_BOUNCE = 800

onready var sprite: Sprite = $Sprite
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var state_machine: Node = $StateMachine
onready var jump_grace: Timer = $JumpGrace
onready var hand_ray: RayCast2D = $HandRay
onready var foot_ray: RayCast2D = $FootRay
onready var collect_label: Label = $CanvasLayer/Control/Collectables/Label
onready var collect_anim_player: AnimationPlayer = $CanvasLayer/Control/Collectables/AnimationPlayer
onready var boost_hitbox: Area2D = $BoostHitbox
onready var combo_manager: Node = $ComboManager
onready var combo_label: Label = $CanvasLayer/Control/ComboLabel

var can_boost: bool = true
var prev_on_floor: bool = false
var jumped : bool = false
var dir_input: Vector2 = Vector2()
var collectables: int = 1 setget set_collectables

func default_movement(delta: float) -> void:
	# Start the gravity with some speed so that collision with floor is always detected
	if velocity.y == 0:
		velocity.y = INIT_GRAVITY
	
	velocity.y += delta * GRAVITY
	
	dir_input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir_input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	var targ = dir_input.x * MAX_X_SPEED
	var delta_x = targ - velocity.x
	var max_displacement = (ACCELERATION if (sign(delta_x)==sign(velocity.x) or sign(velocity.x)==0) else DECELERATION) * delta
	velocity.x += clamp(delta_x, -max_displacement, max_displacement)
	
	velocity.y = min(velocity.y, MAX_Y_SPEED)
	
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# Start grace timer if leaving floor
	if not is_on_floor() and prev_on_floor:
		jump_grace.start()
		
	prev_on_floor = is_on_floor()
	
	if is_on_floor() or (jump_grace.time_left != 0 and velocity.y >= 0):
		jumped = false
		if Input.is_action_just_pressed("ui_select"):
			jump()
			jumped = true
	
	if !is_on_floor() && jumped && velocity.y < 0 && !Input.is_action_pressed("ui_select"):
		velocity.y *= JUMP_DROP_MULTIPLIER
	
	if can_wall_jump():
		velocity.x = 0
		jumped = false
		state_machine.set_deferred("current_state", "StateOnWall")
		
	handle_sprite_flip()
		
	if get_slide_count() == 0 and not hanging_off_wall():
		var snap = Vector2(WALL_SNAP_DIST, 0) * (-1 if sprite.flip_h else 1)
			
		if test_move(transform, snap):
			if Input.is_action_just_pressed("ui_select"):
				can_boost = true
				# Not multiplied by delta because this is the real distance to move
				move_and_collide(snap)
				#state_machine.set_deferred("current_state", "StateOnWall")
				jump(true)
				
	if is_on_floor() or is_on_wall():
		can_boost = true
		
func default_animation(delta: float) -> void:
	if velocity.y == 0:
		if velocity.x == 0:
			anim_player.play("player_idle")
		elif sign(velocity.x) != sign(dir_input.x) and sign(dir_input.x) != 0:
			anim_player.play("player_turn_around")
		else:
			anim_player.play("player_run", -1, velocity.x/MAX_X_SPEED)
	else:
		if velocity.y > 0:
			anim_player.play("player_air_down")
		else:
			anim_player.play("player_air_up")
			
func default_collisions() -> void:
	var bounced = false
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			if get_slide_collision(i).collider.is_in_group("enemies"):
				jumped = true
				jump(false, BOUNCE_JUMP_SPEED)
				get_slide_collision(i).collider.jumped_on()
				bounced = true
		
	if is_on_floor() and not bounced:
		combo_manager.reset_combo()

func jump(off_wall = false, power = JUMP_SPEED) -> void:
	jump_grace.stop()
	
	if off_wall:
		velocity = WALL_JUMP_SPEED * Vector2((1 if $Sprite.flip_h else -1), 1)
	else:
		velocity.y = -power
	
func knockback(vector: Vector2, damage=1) -> void:
	if state_machine.current_state != "StateDeath":
		velocity = vector
		state_machine.current_state = "StateKnockback"
		self.collectables -= 1
	
func hanging_off_wall() -> bool:
	hand_ray.enabled = true
	foot_ray.enabled = true
	
	hand_ray.cast_to = Vector2(64, 0) * (-1 if sprite.flip_h else 1)
	foot_ray.cast_to = Vector2(64, 0) * (-1 if sprite.flip_h else 1)
	return not hand_ray.is_colliding() or not foot_ray.is_colliding() or is_on_floor()
	
	hand_ray.enabled = false
	foot_ray.enabled = false
	
func handle_sprite_flip() -> void:
	if velocity.x != 0:
		sprite.offset.x = sign(velocity.x) * 16
		sprite.flip_h = velocity.x < 0
		
func can_wall_jump() -> bool:
	return not is_on_floor() and is_on_wall() and not hanging_off_wall()
	
func ready_to_boost() -> bool:
	return can_boost and dir_input != Vector2() and (dir_input.y != 1 or not is_on_floor()) and (abs(dir_input.x) != 1 or not is_on_wall())

func set_collectables(to: int) -> void:
	collectables = to
	collect_label.text = str(to)
	collect_anim_player.play("collect_grow")
	if collectables <= 0:
		$HitStop.wait_time = 0.5
		hit_stop()
		state_machine.current_state = "StateDeath"

func _on_BoostHitbox_body_entered(body):
	if body.is_in_group("enemies"):
		
		body.boosted_into(velocity, position)
		
		if body.is_in_group("bounce") and velocity.y > 0:
			velocity.y = -BOOST_BOUNCE
			state_machine.current_state = "StateDefault"
			can_boost = true
			body.jumped_on()
			combo_manager.add_combo(combo_manager.Combo.BOOSTHIT)
		else:
			velocity = Vector2()
			
		hit_stop()
		
func hit_stop():
	$HitStop.start()
	get_tree().paused = true

func _on_HitStop_timeout():
	get_tree().paused = false

func _on_ComboLabel_item_rect_changed():
	if combo_label:
		combo_label.rect_pivot_offset = Vector2(1, 0) * combo_label.rect_size / 2


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "player_death":
		get_tree().reload_current_scene()
