extends NonPlayableCharacter

var should_lay_egg : bool = false

func _ready() -> void:
	walk_cycle = randi_range(min_walk_cycle, max_walk_cycle)
	# Usamos connect con string para evitar el error de tipo Node
	GameTime.connect("day_ended", _on_new_day)

func _on_new_day() -> void:
	should_lay_egg = true
