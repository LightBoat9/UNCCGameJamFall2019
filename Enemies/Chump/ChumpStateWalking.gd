extends Node

var chump
onready var timer: Timer = $AlertExtraTime
onready var caster: RayCast2D = get_owner().get_node("GroundChecker")
var storedRayDirection: Vector2
onready var anim_player = $"../../AnimationPlayer"
onready var hitbox = $"../../HitBox/CollisionShape2D"

func _ready():
	chump = get_owner()
	storedRayDirection = caster.cast_to

func state_entered() -> void:
	anim_player.play("chump_walking")
	caster.enabled = true
	
	hitbox.set_deferred("disabled", false)

func state_exited() -> void:
	caster.enabled = false
	timer.stop()
	hitbox.set_deferred("disabled", true)

func state_physics_process(delta: float) -> void:
	if chump.is_on_wall() || !caster.is_colliding():
		chump.flip()
	
	if !chump.evaluate_sight(chump.player.position):
		if timer.is_stopped():
			timer.start()
	elif !timer.is_stopped():
		timer.stop()
	
	for i in range(chump.get_slide_count()):
		var col = chump.get_slide_collision(i)
		if col.collider.is_in_group("player"):
			chump.player.knockback(Vector2(500 * -chump.dir(), -250))
	
	chump.velocity.x = chump.dir() * chump.WALKSPEED
	update_caster()

func update_caster():
	var castTo: Vector2 = storedRayDirection
	castTo.x *= -chump.dir()
	caster.cast_to = castTo

func _on_AlertExtraTime_timeout():
	get_parent().set_current_state("StateDefault")
