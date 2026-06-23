extends CanvasLayer

# =============================================================
#  ClockUI — Reloj estilo Stardew Valley
#  Jerarquía real:
#  ClockUI (CanvasLayer) ← este script
#  ├─ ClockPanel (NinePatchRect)
#  │  ├─ SlotLeft (NinePatchRect)
#  │  │  └─ DayIcon (TextureRect)
#  │  ├─ SlotRight (Control)
#  │  │  └─ Arrow (Sprite2D)
#  │  └─ DayBadge (NinePatchRect)
#  │     └─ DayLabel (Label)
#  └─ MoneyBadge (NinePatchRect)
#     └─ MoneyLabel (Label)
# =============================================================

@onready var day_icon    : TextureRect = $ClockPanel/SlotLeft/DayIcon
@onready var day_label   : Label       = $ClockPanel/DayBadge/DayLabel
@onready var money_label : Label       = $MoneyBadge/MoneyLabel

# --- Única textura de flecha ---
const TEX_ARROW := preload("res://Assets/weather/midday_arrow.png")

# --- Iconos de momento del día ---
const TEX_DAY_ICON    := preload("res://Assets/weather/Day.png")
const TEX_MIDDAY_ICON := preload("res://Assets/weather/Midday.png")
const TEX_NIGHT_ICON  := preload("res://Assets/weather/Night.png")

# --- Tiempo del día (en minutos de juego) ---
const MINUTE_START := 360    # 6:00 am
const MINUTE_END   := 1320   # 10:00 pm
const MORNING_END  := 720    # 12:00 pm
const EVENING_END  := 1080   # 6:00 pm

const DAY_NAMES : Array[String] = ["MON","TUE","WED","THU","FRI","SAT","SUN"]

# --- Calendario / estaciones ---
const DAYS_PER_SEASON := 28
const SEASON_NAMES : Array[String] = ["Primavera", "Verano", "Otoño", "Invierno"]

# --- Ángulos de la flecha ---
const ARROW_ANGLE_START : float = -135.0  # 6am
const ARROW_ANGLE_END   : float =   90.0  # 10pm

# --- Velocidad: 1 minuto de juego = 1 minuto real ---
# 16 horas de juego (6am-10pm) = 960 minutos de juego = 960 minutos reales
# Para testing rápido: 1 "cambio" (1 minuto de juego) ocurre cada 1 segundo real
var minutes     : float = MINUTE_START
var time_speed  : float = 1.0   # 1 minuto de juego por segundo real (modo test)
var running     : bool  = true

# --- Calendario ---
var current_day    : int = 1   # SIEMPRE empieza en 1 — día del mes/estación
var current_season : int = 0   # índice en SEASON_NAMES
var total_days_elapsed : int = 0  # contador absoluto, nunca se resetea — útil para debug
var _weekday_offset : int = 0  # offset aleatorio — solo afecta el NOMBRE del día (MON,TUE...)

var money : int = 0
var _last_period : int = -1

# Flag para asegurar que day_ended solo se emita UNA vez por día
var _day_already_ended : bool = false

signal day_ended
signal hour_changed(hour: int)
signal period_changed(period: int)
signal money_changed(total: int)
signal season_changed(season_index: int)

# =============================================================
func _ready() -> void:

	# El día del mes SIEMPRE empieza en 1.
	# Solo el NOMBRE del día de la semana (MON, TUE...) es aleatorio,
	# para variar qué día cae el inicio de la partida.
	_weekday_offset = randi_range(0, 6)

	_refresh()

func _process(delta: float) -> void:
	if not running:
		return

	var prev_hour : int = get_hour()
	minutes += time_speed * delta

	# Fin del día — SOLO se dispara una vez gracias al flag
	if minutes >= MINUTE_END and not _day_already_ended:
		minutes = MINUTE_END
		running = false
		_day_already_ended = true
		_refresh()
		emit_signal("day_ended")
		return

	if get_hour() != prev_hour:
		emit_signal("hour_changed", get_hour())

	_refresh()

# =============================================================
func _refresh() -> void:
	_update_day_label()
	_update_icon()

func _update_day_label() -> void:
	# Usamos current_day - 1 para que el Día 1 corresponda al offset inicial aleatorio
	var day_index : int = (current_day - 1 + _weekday_offset) % 7
	var dow : String = DAY_NAMES[day_index]
	day_label.text = "%s. %d" % [dow, current_day]

func _update_icon() -> void:
	var period : int = _get_period()
	if period == _last_period:
		return
	_last_period = period
	match period:
		0: day_icon.texture = TEX_DAY_ICON
		1: day_icon.texture = TEX_MIDDAY_ICON
		2: day_icon.texture = TEX_NIGHT_ICON
	emit_signal("period_changed", period)


func _get_period() -> int:
	if minutes < MORNING_END:
		return 0
	elif minutes < EVENING_END:
		return 1
	return 2

# =============================================================
#  API PÚBLICA — TIEMPO
# =============================================================
func get_hour() -> int:
	return int(minutes / 60.0)

func get_minute() -> int:
	return int(fmod(minutes, 60.0))

func get_time_string() -> String:
	return "%02d:%02d" % [get_hour(), get_minute()]

func get_minutes_remaining() -> int:
	return int(MINUTE_END - minutes)

func get_day_progress() -> float:
	return (minutes - MINUTE_START) / (MINUTE_END - MINUTE_START)

func set_paused(paused: bool) -> void:
	running = not paused

# =============================================================
#  API PÚBLICA — DINERO
# =============================================================
func add_money(amount: int) -> void:
	money += amount
	money_label.text = "%dg" % money
	emit_signal("money_changed", money)

func spend_money(amount: int) -> bool:
	if money < amount:
		return false
	money -= amount
	money_label.text = "%dg" % money
	emit_signal("money_changed", money)
	return true

# =============================================================
#  API PÚBLICA — CALENDARIO
# =============================================================
## Avanza al día siguiente. Maneja correctamente el cambio de estación cada 28 días.
func next_day() -> void:
	current_day += 1
	total_days_elapsed += 1

	# Cambio de estación cada 28 días
	if current_day > DAYS_PER_SEASON:
		current_day = 1
		current_season = (current_season + 1) % SEASON_NAMES.size()
		emit_signal("season_changed", current_season)

	# Reset completo del estado del día
	minutes            = MINUTE_START
	_last_period       = -1
	_day_already_ended = false
	running             = true
	_refresh()

func get_season_name() -> String:
	return SEASON_NAMES[current_season]

func get_full_date_string() -> String:
	var day_index : int = (current_day - 1 + _weekday_offset) % 7
	var dow : String = DAY_NAMES[day_index]
	return "%s %d, %s" % [get_season_name(), current_day, dow]

func set_time(minute: int) -> void:
	minutes      = clampf(float(minute), MINUTE_START, MINUTE_END)
	_last_period = -1
	_refresh()

func set_speed(speed: float) -> void:
	time_speed = maxf(0.0, speed)
	
# =============================================================
#  CONEXIÓN DEL BOTÓN (Paso 3)
# =============================================================
func _on_boton_dormir_pressed() -> void:
	next_day() # Llama a la función de arriba para avanzar el día
