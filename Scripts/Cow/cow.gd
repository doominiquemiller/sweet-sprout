extends NonPlayableCharacter

# =============================================================
#  Cow — Vaca NPC (Versión Tiempo Real Automática)
# =============================================================

@onready var state_machine : NodeStateMachine = $StateMachine # Asegúrate de que coincida con el nombre en tu escena

var milk_timer : Timer

func _ready() -> void:
	# Mantenemos tu lógica base de movimiento aleatorio
	walk_cycle = randi_range(min_walk_cycle, max_walk_cycle)
	
	# Creamos un Timer por código para el ciclo de 4 minutos reales
	milk_timer = Timer.new()
	milk_timer.one_shot = false # Ciclo infinito
	milk_timer.autostart = true
	milk_timer.timeout.connect(_on_milk_timer_timeout)
	add_child(milk_timer)
	
	# 4 minutos reales = 240 segundos
	milk_timer.start(240.0)
	print("[Vaca] Temporizador de leche iniciado: 4 minutos reales de forma autónoma.")

func _on_milk_timer_timeout() -> void:
	if state_machine:
		# Forzamos la transición al estado Milk sin importar qué esté haciendo la vaca
		state_machine.transition_to("milk")
		print("[Vaca] ¡Es hora de ordeñar! Forzando transición a MilkState.")
	else:
		print("⚠️ [Vaca] ERROR: No se encontró el nodo NodeStateMachine en la escena de la vaca.")
