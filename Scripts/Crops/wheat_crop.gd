extends "res://Scripts/Crops/base_crop.gd"
class_name WheatCrop

# =============================================================
#  WHEAT CROP - Cultivo de Trigo (Spritesheet Horizontal)
# =============================================================

# Declarar la variable aquí también
@export var wheat_sprite_sheet: Texture2D = preload("res://Assets/Crops/wheat_sheet.png")
@export var wheat_frame_width: int = 16
@export var wheat_frame_height: int = 48

func _ready() -> void:
	# Configurar tipo de cultivo
	crop_type = "wheat"
	stages = 6
	
	# Asignar valores al padre
	sprite_sheet = wheat_sprite_sheet
	frame_width = wheat_frame_width
	frame_height = wheat_frame_height
	
	# Configurar datos específicos del trigo
	crop_data = {
		"harvest_item": "wheat",
		"harvest_count": 2
	}
	
	# Llamar al _ready del padre
	super._ready()
	
	# Configurar el sprite
	if sprite:
		sprite.scale = Vector2(2.5, 2.5)
		sprite.centered = true

func collect_harvest() -> void:
	if not is_ready:
		print("[WheatCrop] El trigo aún no está listo")
		return
	
	var harvest_count = crop_data.get("harvest_count", 2)
	
	var bonus_chance = 0.2
	if randf() < bonus_chance:
		harvest_count += 1
		print("[WheatCrop] ¡Cosecha extra! +1 trigo")
	
	if Inventory.has_method("add_item"):
		Inventory.add_item("wheat", harvest_count)
	
	print("[WheatCrop] Cosechados %d trigos" % harvest_count)
	queue_free()
