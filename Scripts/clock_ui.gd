extends CanvasLayer


@onready var day_icon    : TextureRect = $ClockPanel/SlotLeft/DayIcon
@onready var arrow       : TextureRect = $ClockPanel/SlotRight/Arrow
@onready var day_label   : Label       = $ClockPanel/DayBadge/DayLabel
@onready var money_label : Label       = $MoneyBadge/MoneyLabel

# --- Única textura de flecha ---
const TEX_ARROW := preload("res://Assets/weather/midday_arrow.png")

# --- Iconos de momento del día ---
const TEX_DAY_ICON    := preload("res://Assets/weather/Day.png")
const TEX_MIDDAY_ICON := preload("res://Assets/weather/Midday.png")
const TEX_NIGHT_ICON  := preload("res://Assets/weather/Night.png")

# --- Tiempo ---
const MINUTE_START := 360    # 6:00 am
const MINUTE_END   := 1320   # 10:00 pm
const MORNING_END  := 720    # 12:00 pm
const EVENING_END  := 1080   # 6:00 pm

const DAY_NAMES : Array[String] = ["MON","TUE","WED","THU","FRI","SAT","SUN"]

var minutes          : float = MINUTE_START
var time_speed       : float = 1.4
var current_day      : int   = 1
var money            : int   = 0
var running          : bool  = true
var _last_period     : int   = -1
# Ángulo inicial (6am) y final (10pm) de la flecha — ajusta START para moverla
const ARROW_ANGLE_START : float = -45.0 # cambia este valor hasta que quede donde quieres
const ARROW_ANGLE_END   : float =   45.0  # cambia este para donde termina (10pm)

signal day_ended
signal hour_changed(hour: int)
signal period_changed(period: int)
signal money_changed(total: int)

# =============================================================
func _ready() -> void:
	# Fijar la flecha una sola vez — siempre midday_arrow
	arrow.texture = TEX_ARROW
	# La rotación la controla 100% el script — ignora la del editor
	_refresh()

func _process(delta: float) -> void:
	if not running:
		return
	var prev_hour : int = get_hour()
	minutes += time_speed * delta
	if minutes >= MINUTE_END:
		minutes = MINUTE_END
		running = false
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
	_update_arrow_rotation()

func _update_day_label() -> void:
	var dow : String = DAY_NAMES[(current_day - 1) % 7]
	day_label.text = "%s. %d" % [dow, current_day]

# El icono izquierdo sigue cambiando según hora del día
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



func _update_arrow_rotation() -> void:
	var t : float = (minutes - MINUTE_START) / (MINUTE_END - MINUTE_START)
	arrow.rotation_degrees = lerpf(ARROW_ANGLE_START, ARROW_ANGLE_END, clampf(t, 0.0, 1.0))

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

func next_day() -> void:
	current_day += 1
	minutes      = MINUTE_START
	_last_period = -1
	running      = true
	arrow.texture = TEX_ARROW
	arrow.rotation_degrees = ARROW_ANGLE_START  # Volver al inicio del día
	_refresh()

func set_time(minute: int) -> void:
	minutes      = clampf(float(minute), MINUTE_START, MINUTE_END)
	_last_period = -1
	_refresh()

func set_speed(speed: float) -> void:
	time_speed = maxf(0.0, speed)
