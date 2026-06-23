extends CanvasLayer

# =============================================================
#  SleepScreen — Pantalla de dormir
# =============================================================

@onready var day_label    : Label         = $Panel/DayLabel
@onready var money_label  : Label         = $Panel/MoneyRow/MoneyLabel
@onready var sleep_button : TextureButton = $Panel/SleepButton

# Cambiamos el nombre a player_slept para que coincida con world.gd
signal player_slept 

var clock : Node = null
var _money_at_day_start : int = 0

# =============================================================
func _ready() -> void:
	visible = false
	# Conectamos el botón visual a nuestra función interna
	sleep_button.pressed.connect(_on_sleep_pressed)

## Llamado por GameManager o World cuando el reloj llega al fin del día
func show_screen() -> void:
	visible = true

	if not clock:
		day_label.text = "¡Día completado!"
		money_label.text = "+0g hoy"
		return

	# CORREGIDO: Ahora extrae el texto exacto (Ej: "WED. 1") desde el ClockUI
	var clock_label : Label = clock.get_node_or_null("ClockPanel/DayBadge/DayLabel")
	if clock_label:
		day_label.text = "%s completado" % clock_label.text
	else:
		var total_days : int = clock.get("total_days_elapsed")
		day_label.text = "Día %d completado" % (total_days + 1)

	var money  : int = clock.get("money")
	var earned : int = money - _money_at_day_start
	money_label.text = "+%dg hoy" % max(0, earned)

## Llamar al iniciar la partida y tras cada next_day() para resetear el contador
func reset_daily_tracking() -> void:
	if clock:
		_money_at_day_start = clock.get("money")

# =============================================================
func _on_sleep_pressed() -> void:
	visible = false
	
	# CORREGIDO: Solo emitimos la señal. world.gd se encargará de llamar a next_day() UNA Sola vez.
	player_slept.emit() 
	
	# Reseteamos el tracking para el dinero del día siguiente
	reset_daily_tracking()
