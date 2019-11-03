extends KinematicBody2D

export var sightRange: Vector2 = Vector2(256, 32)
export var walkSpeed: float = 200

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite
onready var alertTimer: Timer = $AlertExtraTime
onready var groundChecker: RayCast2D = $GroundChecker
var storedRayDirection: Vector2

var player = null
var walking: bool = false
var stunned: bool = false

func _ready():
	add_to_group("enemies")
	anim_player.play("chump_idle")
	player = get_node("/root/World/Player") #attempt to get player
	storedRayDirection = groundChecker.cast_to
	
	if (player):
		# print("Got reference to player")
		pass

func jumped_on():
	anim_player.stop()
	anim_player.play("chump_squish_small")
	stunned = true
	walking = false
	groundChecker.enabled = false

func _physics_process(delta):
	if (player && !stunned):
		player_update()
	
	if walking:
		move_and_slide(Vector2(walkSpeed * dir(),0))
		
		#checking for stable ground ahead
		
		for i in range(get_slide_count()):
			var col = get_slide_collision(i)
			if col.collider.is_in_group("player"):
				player.knockback(Vector2(500 * dir(), -250))
		
		if !groundChecker.is_colliding():
			# print("Unstable ground ahead; turning around")
			sprite.flip_h = !sprite.flip_h
		elif is_on_wall():
			# print("Bonked on a wall; turning around")
			sprite.flip_h = !sprite.flip_h
		
		updateGroundChecker()

func updateGroundChecker():
	var castTo: Vector2 = storedRayDirection
	castTo.x *= -dir()
	groundChecker.cast_to = castTo

func _anim_end(anim : String):
	if anim == "chump_alert":
		walking = true
		groundChecker.enabled = true
		updateGroundChecker()
		anim_player.play("chump_walking")
	elif anim != "chump_walking":
		anim_player.play("chump_idle")
		stunned = false

#assumes player is a valid reference
func player_update():
	if evaluate_sight(player.position):
		if (!walking):
			anim_player.play("chump_alert")
		alertTimer.stop()
	else:
		if (walking && alertTimer.is_stopped()):
			# print("Starting end walk timer")
			alertTimer.start()
		pass

func evaluate_sight(pos: Vector2):
	var delta : Vector2 = pos - position
	return sign(delta.x) == (1 if sprite.flip_h else -1) and \
		abs(delta.x)<=sightRange.x && abs(delta.y)<=sightRange.y

func dir():
	return (1 if sprite.flip_h else -1)

func timesUp():
	# print("Time's up; Time to stop walking")
	anim_player.play("chump_idle")
	walking = false
	groundChecker.enabled = false
