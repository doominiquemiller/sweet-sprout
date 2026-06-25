extends StaticBody2D

# =============================================================
#  FruitTree — Mecanismo Idéntico al Arbusto (4 Frames)
# =============================================================

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

const ANIM_MAP : Dictionary = {
	"apple":  "tree_apple",
	"orange": "tree_orange",
	"peach":  "tree_peach",
	"pear":   "tree_pear",
}

# IDs exactos de los ítems en tu inventario
const FRUIT_ITEM : Dictionary = {
	"apple":  "apple",
	"orange": "orange",
	"peach":  "peach",
	"pear":   "pear",
}

var fruit_type     : String = ""
var is_planted     : bool   = false
var is_ready       : bool   = false

var _produced_morning_this_day   : bool = false
var _produced_afternoon_this_day : bool = false

func _ready() -> void:
	add_to_group("planted_trees")
	z_index = 1
	if sprite:
		sprite.position = Vector2.ZERO

func plant(type: String) -> void:
	if not ANIM_MAP.has(type):
		return

	fruit_type = type
	is_planted = true
	is_ready = false

	sprite.stop()
	sprite.animation = ANIM_MAP[fruit_type]
	sprite.frame = 0 
	_actualizar_escala()

func check_hourly_growth(hour: int) -> void:
	if not is_planted:
		return
		
	# Frame 0 -> Frame 1 (Brote a Joven)
	if hour >= 7 and hour < 9 and sprite.frame == 0:
		sprite.frame = 1

	# Frame 1 -> Frame 2 (Joven a Adulto listo)
	if hour >= 11 and sprite.frame == 1:
		sprite.frame = 2

	# Mañana: Genera fruta (Frame 2 -> Frame 3)
	if hour >= 13 and hour < 15:
		if not _produced_morning_this_day and sprite.frame == 2:
			_produced_morning_this_day = true
			_spawn_fruit()

	# Tarde: Genera fruta (Frame 2 -> Frame 3)
	elif hour >= 16 and hour < 20:
		if not _produced_afternoon_this_day and sprite.frame == 2:
			_produced_afternoon_this_day = true
			_spawn_fruit()

	_actualizar_escala()

func _spawn_fruit() -> void:
	sprite.frame = 3 
	is_ready = true
	_actualizar_escala()

func _actualizar_escala() -> void:
	if not sprite:
		return
	if sprite.frame == 0:
		sprite.scale = Vector2(0.5, 0.5) 
	else:
		sprite.scale = Vector2(1.0, 1.0) 

# Mecanismo de recolección idéntico al del arbusto
func _harvest() -> void:
	var item_id : String = FRUIT_ITEM[fruit_type]
	Inventory.add_item(item_id, 1)
	
	is_ready = false
	sprite.frame = 2 # Regresa al estado adulto sin frutas
	_actualizar_escala()
	print("[FruitTree] Cosechado con éxito: %s" % item_id)

func reset_daily_tree_flags() -> void:
	_produced_morning_this_day = false
	_produced_afternoon_this_day = false
