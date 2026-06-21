extends NonPlayableCharacter

# =============================================================
#  Chicken — Gallina NPC
#  Pone un huevo cada vez que cambia el período del día
#  (mañana → tarde → noche)
# =============================================================

var should_lay_egg : bool = false

func _ready() -> void:
	walk_cycle = randi_range(min_walk_cycle, max_walk_cycle)
	# Conectamos la señal del reloj: se dispara cada vez que
	# cambia mañana → tarde → noche
	GameTime.connect("period_changed", _on_period_changed)

func _on_period_changed(_period: int) -> void:
	should_lay_egg = true
