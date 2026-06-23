extends Node

enum Weather {
	SUNNY,    # Soleado
	CLOUDY,   # Nublado
	RAINY,    # Lluvia
	STORMY,   # Tormenta
	WINDY,    # Viento
}

# Probabilidades por defecto (deben sumar 1.0)
const WEATHER_WEIGHTS := {
	Weather.SUNNY:  0.45,
	Weather.CLOUDY: 0.25,
	Weather.RAINY:  0.20,
	Weather.STORMY: 0.05,
	Weather.WINDY:  0.05,
}

const WEATHER_NAMES := {
	Weather.SUNNY:  "Soleado",
	Weather.CLOUDY: "Nublado",
	Weather.RAINY:  "Lluvia",
	Weather.STORMY: "Tormenta",
	Weather.WINDY:  "Viento",
}

var current_weather  : Weather = Weather.SUNNY
var tomorrow_weather  : Weather = Weather.SUNNY

signal weather_changed(new_weather: int)

# =============================================================
func _ready() -> void:
	current_weather  = _pick_random_weather()
	tomorrow_weather  = _pick_random_weather()

## Avanza al día siguiente — llama esto junto con GameTime.next_day()
func advance_day() -> void:
	current_weather  = tomorrow_weather
	tomorrow_weather  = _pick_random_weather()
	emit_signal("weather_changed", current_weather)

func get_weather_name() -> String:
	return WEATHER_NAMES[current_weather]

func is_raining() -> bool:
	return current_weather in [Weather.RAINY, Weather.STORMY]

func is_good_weather() -> bool:
	return current_weather in [Weather.SUNNY, Weather.CLOUDY, Weather.WINDY]

func force_weather(weather: Weather) -> void:
	current_weather = weather
	emit_signal("weather_changed", current_weather)

# =============================================================
func _pick_random_weather() -> Weather:
	var roll := randf()
	var cumulative := 0.0
	for weather in WEATHER_WEIGHTS:
		cumulative += WEATHER_WEIGHTS[weather]
		if roll <= cumulative:
			return weather
	return Weather.SUNNY
