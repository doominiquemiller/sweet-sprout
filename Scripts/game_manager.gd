extends Node

# =============================================================
#  GameTime — Singleton global de tiempo
#  Project Settings → Autoload → nombre: "GameTime"
# =============================================================

var _clock : Node = null

signal day_ended
signal hour_changed(hour: int)
signal period_changed(period: int)
signal money_changed(total: int)
signal season_changed(season_index: int)

# =============================================================
func register(clock_node: Node) -> void:
	_clock = clock_node
	_clock.connect("day_ended",      func(): emit_signal("day_ended"))
	_clock.connect("hour_changed",   func(h): emit_signal("hour_changed", h))
	_clock.connect("period_changed", func(p): emit_signal("period_changed", p))
	_clock.connect("money_changed",  func(m): emit_signal("money_changed", m))
	_clock.connect("season_changed", func(s): emit_signal("season_changed", s))

# =============================================================
#  PROXY — usa call() para invocar métodos sin error de tipo Node
# =============================================================
func get_hour() -> int:
	if not _clock: return 6
	return _clock.call("get_hour")

func get_minute() -> int:
	if not _clock: return 0
	return _clock.call("get_minute")

func get_time_string() -> String:
	if not _clock: return "06:00"
	return _clock.call("get_time_string")

func get_day_progress() -> float:
	if not _clock: return 0.0
	return _clock.call("get_day_progress")

func get_minutes_remaining() -> int:
	if not _clock: return 960
	return _clock.call("get_minutes_remaining")

func get_current_day() -> int:
	if not _clock: return 1
	return _clock.get("current_day")

func get_total_days_elapsed() -> int:
	if not _clock: return 0
	return _clock.get("total_days_elapsed")

func get_season_name() -> String:
	if not _clock: return "Primavera"
	return _clock.call("get_season_name")

func get_full_date_string() -> String:
	if not _clock: return ""
	return _clock.call("get_full_date_string")

func get_money() -> int:
	if not _clock: return 0
	return _clock.get("money")

func add_money(amount: int) -> void:
	if _clock: _clock.call("add_money", amount)

func spend_money(amount: int) -> bool:
	if not _clock: return false
	return _clock.call("spend_money", amount)

func set_paused(paused: bool) -> void:
	if _clock: _clock.call("set_paused", paused)

func next_day() -> void:
	if _clock: _clock.call("next_day")

func set_time(minute: int) -> void:
	if _clock: _clock.call("set_time", minute)

func set_speed(speed: float) -> void:
	if _clock: _clock.call("set_speed", speed)

# =============================================================
#  HELPERS
# =============================================================
func is_daytime() -> bool:
	return get_hour() >= 6 and get_hour() < 18

func is_nighttime() -> bool:
	return get_hour() >= 18

func is_running_late() -> bool:
	return get_minutes_remaining() < 120

func consume_time(minutes_cost: int) -> bool:
	if not _clock: return false
	if minutes_cost >= get_minutes_remaining(): return false
	var new_minutes : int = get_hour() * 60 + get_minute() + minutes_cost
	set_time(new_minutes)
	return true
