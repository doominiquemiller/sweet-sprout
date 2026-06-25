extends Node2D

@onready var clock            : CanvasLayer     = $clock_ui as CanvasLayer
@onready var sleep_screen     : CanvasLayer     = $SleepScreen as CanvasLayer
@onready var canvas_modulate : CanvasModulate  = $CanvasModulate as CanvasModulate
@onready var planting_system : Node2D          = $PlantingSystem

# --- Configuración del color por hora para el CanvasModulate ---
const COLOR_NIGHT   = Color("353738") # Noche oscura (Cerrado / Madrugada)
const COLOR_DAWN    = Color("cbe0de") # Amanecer cálido (6:00 AM)
const COLOR_DAY     = Color("dce0d2") # Luz pura del día (8:00 AM - 4:00 PM)
const COLOR_SUNSET  = Color("ba7c54") # Atardecer naranja (6:00 PM)
const COLOR_EVENING = Color("577297") # Anochecer azulado (7:00 PM)

# CORREGIDO: Variable de control para mandar el pulso a las colmenas una sola vez por minuto
var _last_checked_minute : int = -1

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
	
	# Sincronización exacta de señales, crecimiento de huerto y dinero
	sleep_screen.player_slept.connect(func():
		# 1. Avanzamos el clima del juego
		WeatherSystem.advance_day()
		
		# 2. Avanzamos el reloj al día siguiente (Día 1 -> Día 2 -> etc.)
		clock.next_day()
		
		# 3. Reiniciamos el rastreo del dinero al iniciar el nuevo día oficial
		sleep_screen.reset_daily_tracking()
		
		# 4. Forzamos el avance de crecimiento en árboles y arbustos frutales
		_advance_fruit_trees()
		
		# 5. CORREGIDO: Reinicia los bloqueadores de producción diaria de las colmenas
		get_tree().call_group("beehives", "reset_daily_production_flags")
		get_tree().call_group("planted_bushes", "reset_daily_bush_flags")
		get_tree().call_group("planted_trees", "reset_daily_tree_flags")
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
	Inventory.add_item("blackberry_seeds", 1)
	Inventory.add_item("blueberry_seeds", 1)
	Inventory.add_item("raspberry_seeds", 1)
	
	print("¡Semillas de prueba añadidas con éxito al inventario global!")

func _process(_delta: float) -> void:
	_update_ambient_light()
	_check_beehive_production_schedule()

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

## CORREGIDO: Verifica y envía la señal a las colmenas de forma optimizada una sola vez por minuto
func _check_beehive_production_schedule() -> void:
	var current_minute : int = clock.get_minute()
	
	if current_minute != _last_checked_minute:
		_last_checked_minute = current_minute
		
		var current_hour : int = clock.get_hour()
		get_tree().call_group("beehives", "check_production", current_hour)
		
		get_tree().call_group("planted_bushes", "check_hourly_growth", current_hour)
		
		get_tree().call_group("planted_trees", "check_hourly_growth", current_hour)

## Avanza de etapa tanto los árboles como los nuevos arbustos de bayas al cambiar de día
func _advance_fruit_trees() -> void:
	# 1. Buscamos y avanzamos todas las parcelas de árboles del mapa
	var tree_spaces = get_tree().get_nodes_in_group("tree_space")
	for space in tree_spaces:
		if is_instance_valid(space) and space.has_method("advance_hosted_tree"):
			space.advance_hosted_tree() # Le dice a la tierra: "Haz crecer tu árbol"
			
	# 2. NUEVO: Buscamos y avanzamos todas las parcelas de arbustos (Crop Spaces) del mapa
	var crop_spaces = get_tree().get_nodes_in_group("crop_space")
	for space in crop_spaces:
		if is_instance_valid(space) and space.has_method("advance_hosted_bush"):
			space.advance_hosted_bush() # Le dice a la tierra: "Haz crecer tu arbusto"
