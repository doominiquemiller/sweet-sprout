extends CanvasLayer

# =============================================================
#  ClockUI — Reloj estilo Stardew Valley
# =============================================================

@onready var day_icon    : TextureRect = $ClockPanel/SlotLeft/DayIcon
@onready var day_label   : Label       = $ClockPanel/DayBadge/DayLabel
@onready var money_label : Label       = $MoneyBadge/MoneyLabel

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

var minutes     : float = MINUTE_START
var time_speed  : float = 1.0
var running     : bool  = true

# --- Calendario ---
var current_day    : int = 1
var current_season : int = 0
var total_days_elapsed : int = 0
var _weekday_offset : int = 0

var _last_period : int = -1
var _day_already_ended : bool = false

signal day_ended
signal hour_changed(hour: int)
signal period_changed(period: int)
signal season_changed(season_index: int)

# =============================================================
func _ready() -> void:
	# Conectar al dinero global
	Global.money_changed.connect(_on_money_changed_global)
	
	_weekday_offset = randi_range(0, 6)
	_refresh()

func _process(delta: float) -> void:
	if not running:
		return

	var prev_hour : int = get_hour()
	minutes += time_speed * delta

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
	if money_label:
		money_label.text = "%dg" % Global.money

func _update_day_label() -> void:
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
#  API PÚBLICA
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

func next_day() -> void:
	current_day += 1
	total_days_elapsed += 1

	if current_day > DAYS_PER_SEASON:
		current_day = 1
		current_season = (current_season + 1) % SEASON_NAMES.size()
		emit_signal("season_changed", current_season)

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
#  MANEJO DE SEÑALES
# =============================================================
func _on_money_changed_global(new_amount: int) -> void:
	if money_label:
		money_label.text = "%dg" % new_amount

func _on_boton_dormir_pressed() -> void:
	next_day()

# =============================================================
#  BOTONES DE LA TIENDA
# =============================================================
@export var store_scene: PackedScene

func _on_store_button_pressed() -> void:
	print("Abriendo tienda...")
	var store = store_scene.instantiate()
	add_child(store)

func _on_texture_button_pressed() -> void:
	var store = store_scene.instantiate()
	add_child(store)

func _on_close_button_pressed() -> void:
	queue_free()
