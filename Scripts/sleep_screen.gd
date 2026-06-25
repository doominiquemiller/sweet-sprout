extends CanvasLayer

# =============================================================
#  SleepScreen — Pantalla de dormir
# =============================================================

@onready var day_label    : Label         = $Panel/DayLabel
@onready var money_label  : Label         = $Panel/MoneyRow/MoneyLabel
@onready var sleep_button : TextureButton = $Panel/SleepButton

# Señal que escucha world.gd para hacer el Fade Out y cambiar el día
signal player_slept 

var clock : Node = null
var _money_at_day_start : int = 0

# =============================================================
func _ready() -> void:
	visible = false
	# Conectamos el botón visual a nuestra función interna
	sleep_button.pressed.connect(_on_sleep_pressed)

## Llamado por GameManager o World cuando el reloj llega al fin del día o vas a la cama
func show_screen() -> void:
	visible = true

	if not clock:
		day_label.text = "¡Día completado!"
		money_label.text = "+0g hoy"
		return

	# Extrae el texto exacto (Ej: "WED. 1") desde el ClockUI
	var clock_label : Label = clock.get_node_or_null("ClockPanel/DayBadge/DayLabel")
	if clock_label:
		day_label.text = "%s completado" % clock_label.text
	else:
		var total_days : int = clock.get("total_days_elapsed")
		day_label.text = "Día %d completado" % (total_days + 1)

	# Cálculo de ganancias del día actual
	var current_money : int = clock.get("money")
	var earned : int = current_money - _money_at_day_start
	money_label.text = "+%dg hoy" % max(0, earned)

## Llamar AL DESPERTAR (tras ejecutar next_day() en el reloj) para registrar el inicio económico
func reset_daily_tracking() -> void:
	if clock:
		_money_at_day_start = clock.get("money")

# =============================================================
func _on_sleep_pressed() -> void:
	visible = false
	
	print("[SleepScreen] El jugador presionó dormir... Procesando crecimiento del huerto.")
	
	# 1. Hacemos crecer los árboles frutales de forma segura
	var active_trees = get_tree().get_nodes_in_group("planted_trees")
	
	for tree in active_trees:
		# Validamos que el árbol no sea una instancia nula liberada previamente
		if is_instance_valid(tree) and tree.has_method("advance_growth_state"):
			tree.advance_growth_state() # Cambia automáticamente el frame del 0 al 1 o 2
	
	# 2. Emitimos la señal para que world.gd corra el cambio de día y Fade Out
	player_slept.emit()
	
	# NOTA: Asegúrate de que en tu 'world.gd', justo después de llamar a clock.next_day(),
	# invoques de vuelta a: sleep_screen.reset_daily_tracking()
	# Esto garantizará que el conteo comience limpio en la mañana.
