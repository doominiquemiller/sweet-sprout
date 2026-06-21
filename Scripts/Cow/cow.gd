extends NonPlayableCharacter

# =============================================================
#  Cow — Vaca NPC
#  Da leche cada vez que cambia el período del día
#  (mañana → tarde → noche), igual que la gallina con los huevos
# =============================================================

var should_give_milk : bool = false

func _ready() -> void:
	walk_cycle = randi_range(min_walk_cycle, max_walk_cycle)
	GameTime.connect("period_changed", _on_period_changed)

func _on_period_changed(_period: int) -> void:
	should_give_milk = true
