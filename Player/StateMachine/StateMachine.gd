extends Node

var current_state: NodePath = NodePath("StateDefault") setget set_current_state

func _ready():
	self.current_state = current_state

func set_current_state(state: NodePath) -> void:
	if get_node(current_state).has_method("state_exited"):
		get_node(current_state).state_exited()
	
	current_state = state
	
	print(get_node(current_state))
	
	if get_node(current_state).has_method("state_entered"):
		get_node(current_state).state_entered()

func _process(delta: float) -> void:
	if get_node(current_state).has_method("state_process"):
		get_node(current_state).state_process(delta)
		
func _physics_process(delta: float) -> void:
	if get_node(current_state).has_method("state_physics_process"):
		get_node(current_state).state_physics_process(delta)
		
