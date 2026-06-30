extends NonPlayableCharacter

# =============================================================
#  Chicken — Gallina NPC (Versión Tiempo Real Automática)
# =============================================================

@onready var state_machine : NodeStateMachine = $StateMachine # Asegúrate de que coincida con el nombre en tu escena

var egg_timer : Timer

func _ready() -> void:
	# Mantenemos tu lógica base de movimiento aleatorio
	walk_cycle = randi_range(min_walk_cycle, max_walk_cycle)
	
	# Creamos un Timer por código para el ciclo de 4 minutos reales
	egg_timer = Timer.new()
	egg_timer.one_shot = false # Ciclo infinito
	egg_timer.autostart = true
	egg_timer.timeout.connect(_on_egg_timer_timeout)
	add_child(egg_timer)
	
	# 4 minutos reales = 240 segundos
	egg_timer.start(240.0)
	print("[Gallina] Temporizador de huevos iniciado: 4 minutos reales de forma autónoma.")

func _on_egg_timer_timeout() -> void:
	if state_machine:
		# Forzamos la transición al estado que pone el huevo (asegúrate de que en la StateMachine se llame "lay")
		state_machine.transition_to("lay")
		print("[Gallina] ¡Es hora de poner un huevo! Forzando transición a LayState.")
	else:
		print("⚠️ [Gallina] ERROR: No se encontró el nodo NodeStateMachine en la escena de la gallina.")
