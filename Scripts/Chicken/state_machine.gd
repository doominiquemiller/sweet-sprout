class_name NodeStateMachine
extends Node

@export var initial_node_state : State
var node_states : Dictionary = {}
var current_node_state : State
var current_node_state_name : String
var parent_node_name: String

func _ready() -> void:
	parent_node_name = get_parent().name

	# DEBUG — lista qué estados se registraron
	print("[", parent_node_name, "] Buscando estados...")
	for child in get_children():
		print("  - hijo encontrado: ", child.name, " es State? ", child is State)
		if child is State:
			node_states[child.name.to_lower()] = child
			child.transition.connect(transition_to)

	print("[", parent_node_name, "] Estados registrados: ", node_states.keys())

	if initial_node_state:
		print("[", parent_node_name, "] Iniciando con: ", initial_node_state.name)
		initial_node_state._on_enter()
		current_node_state = initial_node_state
		current_node_state_name = current_node_state.name.to_lower()
	else:
		print("[", parent_node_name, "] ⚠️ initial_node_state es NULL — no hay estado inicial asignado")

func _process(delta : float) -> void:
	if current_node_state:
		current_node_state._on_process(delta)

func _physics_process(delta: float) -> void:
	if current_node_state:
		current_node_state._on_physics_process(delta)
		current_node_state._on_next_transitions()
		print(parent_node_name , " Current State: ", current_node_state_name)
	else:
		print(parent_node_name, " ⚠️ current_node_state es NULL")

func transition_to(node_state_name : String) -> void:
	print("[", parent_node_name, "] Transición solicitada a: ", node_state_name)
	if node_state_name == current_node_state.name.to_lower():
		return

	var new_node_state = node_states.get(node_state_name.to_lower())

	if !new_node_state:
		print("[", parent_node_name, "] ⚠️ Estado '", node_state_name, "' NO encontrado en node_states")
		return

	if current_node_state:
		current_node_state._on_exit()

	new_node_state._on_enter()

	current_node_state = new_node_state
	current_node_state_name = current_node_state.name.to_lower()
