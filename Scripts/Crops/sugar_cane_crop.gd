extends "res://Scripts/Crops/base_crop.gd"
class_name SugarCaneCrop

# =============================================================
#  SUGAR CANE CROP - Cultivo de Caña de Azúcar (Spritesheet Horizontal)
# =============================================================

# Declarar la variable aquí también
@export var sugar_cane_sprite_sheet: Texture2D = preload("res://Assets/Crops/sugar_cane_sheet.png")
@export var sugar_cane_frame_width: int = 16
@export var sugar_cane_frame_height: int = 48

func _ready() -> void:
	# Configurar tipo de cultivo
	crop_type = "sugar_cane"
	stages = 6
	
	# Asignar valores al padre
	sprite_sheet = sugar_cane_sprite_sheet
	frame_width = sugar_cane_frame_width
	frame_height = sugar_cane_frame_height
	
	# Configurar datos específicos de la caña
	crop_data = {
		"harvest_item": "sugar_cane",
		"harvest_count": 3
	}
	
	# Llamar al _ready del padre
	super._ready()
	
	# Configurar el sprite
	if sprite:
		sprite.scale = Vector2(2.5, 2.5)
		sprite.centered = true

func collect_harvest() -> void:
	if not is_ready:
		print("[SugarCaneCrop] La caña aún no está lista")
		return
	
	var harvest_count = crop_data.get("harvest_count", 3)
	
	var quality_bonus = 1.0
	if _has_sufficient_water():
		quality_bonus = 1.2
		harvest_count = int(harvest_count * quality_bonus)
	
	if Inventory.has_method("add_item"):
		Inventory.add_item("sugar_cane", harvest_count)
	
	print("[SugarCaneCrop] Cosechadas %d cañas" % harvest_count)
	queue_free()

func _has_sufficient_water() -> bool:
	return true
