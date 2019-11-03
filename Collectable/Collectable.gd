extends KinematicBody2D

export var GRAVITY = 200
export var DECELERATION = 200

var player: Node
onready var sprite = $Sprite

var velocity: Vector2 = Vector2()

func _ready() -> void:
	randomize()
	sprite.frame = randi() % sprite.hframes
	
func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
	if velocity.x != 0:
		if abs(velocity.x) > DECELERATION * delta:
			velocity.x -= sign(velocity.x) * DECELERATION * delta
		else:
			velocity.x = 0
	
	velocity = move_and_slide(velocity)

func _on_CollectableArea_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body
		player.get_node("ComboManager").combo_points += 1
		$AnimationPlayer.play("free")
		
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "free":
		queue_free()
