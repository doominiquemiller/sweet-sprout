class_name NodeStateMachine
extends Node

# =============================================================
#  NodeStateMachine — Gestor de Estados del NPC
# =============================================================

@export var initial_node_state : State

var node_states : Dictionary = {}
var current_node_state : State
var current_node_state_name : String
var parent_node_name: String

func _ready() -> void:
	parent_node_name = get_parent().name

	# Registra todos los nodos hijos que sean scripts de Estado (Idle, Walk, Sleep, Milk)
	for child in get_children():
		if child is State:
			node_states[child.name.to_lower()] = child
			child.transition.connect(transition_to)

	# Inicializa el estado por defecto
	if initial_node_state:
		initial_node_state._on_enter()
		current_node_state = initial_node_state
		current_node_state_name = current_node_state.name.to_lower()

func _process(delta : float) -> void:
	if current_node_state:
		current_node_state._on_process(delta)

func _physics_process(delta: float) -> void:
	if current_node_state:
		current_node_state._on_physics_process(delta)
		current_node_state._on_next_transitions()

# Función pública que llama la Vaca al vencerse los 4 minutos
func transition_to(node_state_name : String) -> void:
	if not current_node_state:
		return
		
	# Evita transicionar al mismo estado si ya se encuentra en él
	if node_state_name.to_lower() == current_node_state.name.to_lower():
		return

	var new_node_state = node_states.get(node_state_name.to_lower())

	if !new_node_state:
		print("⚠️ [StateMachine de %s] ERROR: El estado '%s' no existe." % [parent_node_name, node_state_name])
		return

	# Intercambio de estados limpio
	current_node_state._on_exit()
	new_node_state._on_enter()

	current_node_state = new_node_state
	current_node_state_name = current_node_state.name.to_lower()
