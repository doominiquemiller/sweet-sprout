extends Node

enum Weather { SUNNY, CLOUDY }

var current_weather : Weather = Weather.SUNNY
var tomorrow_weather: Weather = Weather.SUNNY

signal weather_changed(new_weather: int)

func _ready() -> void:
	randomize()
	current_weather = _pick_random_weather()
	tomorrow_weather = _pick_random_weather()

func advance_day() -> void:
	current_weather = tomorrow_weather
	tomorrow_weather = _pick_random_weather()
	weather_changed.emit(current_weather)

func _pick_random_weather() -> Weather:
	return Weather.SUNNY if randf() < 0.60 else Weather.CLOUDY
