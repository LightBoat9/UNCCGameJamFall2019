extends "res://BaseClasses/KinematicMotion.gd"

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
onready var state_jump: Node = $StateMachine/StateAirborne

onready var jump_grace: Timer = $JumpGrace
onready var hand_ray: RayCast2D = $HandRay
onready var foot_ray: RayCast2D = $FootRay
onready var collect_label: Label = $CanvasLayer/Control/Collectables/Label
onready var collect_anim_player: AnimationPlayer = $CanvasLayer/Control/Collectables/AnimationPlayer
onready var boost_hitbox: Area2D = $BoostHitbox
onready var combo_manager: Node = $ComboManager
onready var combo: VBoxContainer = $CanvasLayer/Control/Combo
onready var combo_label: Label = $CanvasLayer/Control/Combo/Label
onready var combo_points_label: Label = $CanvasLayer/Control/Combo/PointsLabel

var can_boost: bool = true
var prev_on_floor: bool = false
var jumped : bool = false
var collectables: int = 1 setget set_collectables

var input_dir: Vector2 = Vector2()
var input_jump: bool = false
var input_jumpPressed: bool = false
var input_boost: bool = false

func _physics_process(delta):
	input()

func input():
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	input_jumpPressed = Input.is_action_just_pressed("ui_select")
	input_jump = Input.is_action_pressed("ui_select")
	
	input_boost = Input.is_action_just_pressed("ui_cancel")

func apply_external_force(force: Vector2):
	state_jump.jumped = false
	.apply_external_force(force)
	pass

func accelerate_horizontal(maxSpeed: float, acceleration: float, deceleration: float, delta: float)->void:
	velocity.x = accelerate(velocity.x, maxSpeed * input_dir.x, acceleration * delta, deceleration * delta)
	
func gravity_tick(delta: float)->void:
	velocity.y += delta * GRAVITY

func gravity_tick_custom(gravity: float, delta: float)->void:
	velocity.y += delta * gravity

func vertical_clamp(max_speed: float = MAX_Y_SPEED):
	velocity.y = min(velocity.y, max_speed)

#func default_animation(delta: float) -> void:
#	if velocity.y == 0:
#		if velocity.x == 0:
#			anim_player.play("player_idle")
#		elif sign(velocity.x) != sign(input_dir.x) and sign(input_dir.x) != 0:
#			anim_player.play("player_turn_around")
#		else:
#			anim_player.play("player_run", -1, velocity.x/MAX_X_SPEED)

func default_collisions() -> void:
	var bounced = false
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			if get_slide_collision(i).collider.is_in_group("enemies"):
				state_jump.jumped = true
				jump(false, BOUNCE_JUMP_SPEED)
				state_machine.current_state = "StateAirborne"
				
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
		combo_manager.reset_combo()
		self.collectables -= 1

func rays_setEnable(enabled : bool)->void:
	hand_ray.enabled = enabled
	foot_ray.enabled = enabled

func rays_updateFacing()->void:
	hand_ray.cast_to = Vector2(64, 0) * (-1 if sprite.flip_h else 1)
	foot_ray.cast_to = Vector2(64, 0) * (-1 if sprite.flip_h else 1)

func hanging_off_wall() -> bool:
	return !hand_ray.is_colliding() || !foot_ray.is_colliding() || is_on_floor()

func handle_sprite_flip() -> void:
	if velocity.x != 0:
		sprite.offset.x = sign(velocity.x) * 16
		sprite.flip_h = velocity.x < 0

func can_wall_jump() -> bool:
	return not is_on_floor() and is_on_wall() and not hanging_off_wall()

func ready_to_boost() -> bool:
	return can_boost and input_dir != Vector2() and (input_dir.y != 1 or not is_on_floor()) and (abs(input_dir.x) != 1 or not is_on_wall())

func boost_check()->bool:
	if ready_to_boost() and Input.is_action_just_pressed("ui_cancel"):
		state_machine.current_state = "StateBoost"
		return true
	return false

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
		
		if body.is_in_group("bounce"):
			velocity.y = -BOOST_BOUNCE
			state_machine.current_state = "StateAirborne"
			can_boost = true
			#body.jumped_on()
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
