extends Node2D

@onready var clock           : CanvasLayer     = $clock_ui as CanvasLayer
@onready var sleep_screen    : CanvasLayer     = $SleepScreen as CanvasLayer
@onready var canvas_modulate : CanvasModulate  = $CanvasModulate as CanvasModulate
@onready var planting_system : Node2D = $PlantingSystem

# --- Configuración del color por hora para el CanvasModulate ---
const COLOR_NIGHT   = Color("353738") # Noche oscura (Cerrado / Madrugada)
const COLOR_DAWN    = Color("cbe0de") # Amanecer cálido (6:00 AM)
const COLOR_DAY     = Color("dce0d2") # Luz pura del día (8:00 AM - 4:00 PM)
const COLOR_SUNSET  = Color("eeba77") # Atardecer naranja (6:00 PM)
const COLOR_EVENING = Color("577297") # Anochecer azulado (7:00 PM)

func _ready() -> void:
	# Registrar el reloj en el core de tiempo global
	GameTime.register(clock)
	sleep_screen.clock = clock
	sleep_screen.reset_daily_tracking() # Inicializa el dinero del primer día
	
	# Conectar el final del día automático con la pantalla de dormir
	clock.connect("day_ended", func():
		clock.set_paused(true)
		sleep_screen.show_screen()
	)
	
	# CORREGIDO: Escuchamos la nueva señal 'player_slept'
	sleep_screen.player_slept.connect(func():
		# 1. Avanzamos el clima del juego
		WeatherSystem.advance_day()
		
		# 2. Avanzamos el reloj al día siguiente (Día 1 -> Día 2 -> etc.)
		clock.next_day()
		
		# NUEVO: avanzar todos los árboles 1 día
		_advance_fruit_trees()
	)
	
	get_tree().paused = false
	
	# Esperamos un instante a que el Singleton de inventario cargue sus ranuras visuales
	await get_tree().create_timer(0.1).timeout
	
	# Limpiamos cualquier residuo del arranque para asegurar que sea exactamente 1 de cada una
	Inventory.items.clear()
	Inventory._slot_order.clear()
	
	# Inyectamos las 4 semillas listas para plantar
	Inventory.add_item("apple_seed", 1)
	Inventory.add_item("orange_seed", 1)
	Inventory.add_item("peach_seed", 1)
	Inventory.add_item("pear_seed", 1)
	
	print("¡Semillas de prueba añadidas con éxito al inventario global!")

func _process(_delta: float) -> void:
	_update_ambient_light()

## Controla la transición de color suave del CanvasModulate basada en el reloj
func _update_ambient_light() -> void:
	var hour : int = clock.get_hour()
	var minute : int = clock.get_minute()
	
	# Forzamos a que el factor de tiempo sea un cálculo flotante exacto (0.0 a 1.0)
	var time_factor : float = float(minute) / 60.0 
	
	var target_color : Color = COLOR_DAY
	
	# Sistema de interpolación horaria garantizado de 24 horas
	if hour >= 0 and hour < 5:
		target_color = COLOR_NIGHT
	elif hour == 5:
		target_color = COLOR_NIGHT.lerp(COLOR_DAWN, time_factor)
	elif hour == 6:
		target_color = COLOR_DAWN.lerp(COLOR_DAY, time_factor)
	elif hour >= 7 and hour < 17:
		target_color = COLOR_DAY
	elif hour == 17:
		target_color = COLOR_DAY.lerp(COLOR_SUNSET, time_factor)
	elif hour == 18:
		target_color = COLOR_SUNSET.lerp(COLOR_EVENING, time_factor)
	elif hour == 19:
		target_color = COLOR_EVENING.lerp(COLOR_NIGHT, time_factor)
	else: # De 20:00 a 23:59
		target_color = COLOR_NIGHT
		
	canvas_modulate.color = target_color
	
func _advance_fruit_trees() -> void:
	for tree in get_tree().get_nodes_in_group("fruit_trees"):
		tree.on_day_passed()
