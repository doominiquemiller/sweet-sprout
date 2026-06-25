extends Node2D

# =============================================================
#  FruitBush — Versión Corregida e Independiente de Nodos
# =============================================================

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

const ANIM_MAP : Dictionary = {
	"blackberry": "blackberry",
	"blueberry":  "blueberry",
	"raspberry":  "raspberry",
}

const FRUIT_ITEM : Dictionary = {
	"blackberry": "blackberry_item",
	"blueberry":  "blueberry_item",
	"raspberry":  "raspberry_item",
}

var bush_type      : String = ""
var is_planted     : bool   = false
var is_ready       : bool   = false

var _produced_morning_this_day   : bool = false
var _produced_afternoon_this_day : bool = false

func _ready() -> void:
	add_to_group("planted_bushes")
	z_index = 1

func plant(type: String) -> void:
	if not ANIM_MAP.has(type):
		return

	bush_type = type
	is_planted = true
	is_ready = false

	sprite.stop()
	sprite.animation = ANIM_MAP[bush_type]
	sprite.frame = 0 

func check_hourly_growth(hour: int) -> void:
	if not is_planted:
		return
		
	if hour >= 9 and sprite.frame == 0:
		sprite.frame = 1
		print("[FruitBush] %s creció de brote a arbusto verde (Frame 1)." % bush_type)

	if hour >= 11 and hour < 13:
		if not _produced_morning_this_day and sprite.frame == 1:
			_produced_morning_this_day = true
			_spawn_berries("Mañana")

	elif hour >= 16 and hour < 20:
		if not _produced_afternoon_this_day and sprite.frame == 1:
			_produced_afternoon_this_day = true
			_spawn_berries("Tarde")

func _ready_to_harvest() -> bool:
	return is_ready

func _spawn_berries(momento: String) -> void:
	sprite.frame = 2
	is_ready = true
	print("[FruitBush] ¡El arbusto de %s dio frutos en la %s! (Frame 2)" % [bush_type, momento])

func reset_daily_bush_flags() -> void:
	_produced_morning_this_day = false
	_produced_afternoon_this_day = false

# Función pública para ejecutar la cosecha desde el CropSpace
func collect_harvest() -> void:
	var item_id : String = FRUIT_ITEM[bush_type]
	Inventory.add_item(item_id, 1)
	is_ready = false
	sprite.frame = 1
	print("[FruitBush] Cosechado: %s. Volviendo al estado base." % item_id)
