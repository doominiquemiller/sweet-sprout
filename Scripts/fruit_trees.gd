extends StaticBody2D

# =============================================================
#  FruitTree — Centrado y Detección de HarvestArea Corregida
# =============================================================

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
# Corregido: Apunta al nombre real de tu escena hijo
@onready var harvest_area : Area2D = $HarvestArea 

const ANIM_MAP : Dictionary = {
	"apple":  "tree_apple",
	"orange": "tree_orange",
	"peach":  "tree_peach",
	"pear":   "tree_pear",
}

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
	
	# Ajuste inicial de posición
	if sprite:
		_ajustar_posicion_local()

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

	if hour >= 7 and hour < 9 and sprite.frame == 0:
		sprite.frame = 1
	if hour >= 10 and sprite.frame == 1:
		sprite.frame = 2
		
	if hour >= 12 and hour < 15:
		if not _produced_morning_this_day and sprite.frame == 2:
			_produced_morning_this_day = true
			_spawn_fruit()
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
	
	# Re-ajustamos el desfase cada vez que cambia de tamaño/frame
	_ajustar_posicion_local()

## NUEVO: Corrige el desfase del origen vertical de los árboles altos
func _ajustar_posicion_local() -> void:
	if sprite.frame == 0:
		# Las semillas se quedan en el centro exacto (0,0)
		sprite.position = Vector2.ZERO
	else:
		# Si los frames 1, 2 o 3 quedan muy altos, cambia este -16 por el valor 
		# de píxeles que necesites bajar (ej. Vector2(0, 8) para bajarlo)
		sprite.position = Vector2(0, 0)

func _harvest() -> void:
	var item_id : String = FRUIT_ITEM[fruit_type]
	Inventory.add_item(item_id, 1)

	is_ready = false
	sprite.frame = 2 
	_actualizar_escala()
	print("[FruitTree] Cosechado con éxito: %s" % item_id)

func reset_daily_tree_flags() -> void:
	_produced_morning_this_day = false
	_produced_afternoon_this_day = false
