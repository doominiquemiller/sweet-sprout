extends Node

var _clock : Node = null

signal hour_changed(hour: int)
signal minute_changed(minute: int)

func register(clock_node: Object) -> void:
	if clock_node == null: return
	_clock = clock_node
	_clock.connect("hour_changed", func(h): hour_changed.emit(h))
	_clock.connect("minute_changed", func(m): minute_changed.emit(m))

func get_hour() -> int: return _clock.call("get_hour") if _clock else 6
func get_minute() -> int: return _clock.call("get_minute") if _clock else 0
func get_time_progress() -> float: return _clock.call("get_day_progress") if _clock else 0.0
func get_current_day() -> int:
	if not _clock: return 1
	return _clock.day # Accede directamente a la variable 'day' del reloj original
