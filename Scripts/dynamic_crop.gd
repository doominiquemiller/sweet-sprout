extends Node2D

# =============================================================
#  DynamicCrop — Versión para Animaciones Individuales (image_283cb7)
# =============================================================

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var label  : Label = $InteractionLabel

const FRUIT_ITEM : Dictionary = {
	"wheat":     "wheat_item",
	"sugarcane": "sugarcane.png"
}

var crop_type      : String = ""
var is_planted     : bool   = false
var is_ready       : bool   = false
var is_watered     : bool   = false
var tile_coord     : Vector2i = Vector2i.ZERO

# Etapas: 0 = seed, 1 = grow1, 2 = grow2, 3 = grow3, 4 = fullgrow (Listo)
var growth_stage   : int    = 0 
var harvests_done  : int    = 0
const MAX_HARVESTS : int    = 3

func _ready() -> void:
	add_to_group("planted_crops")
	z_index = 1
	if label:
		label.visible = false

func init_crop(type: String, coord: Vector2i) -> void:
	crop_type = type
	tile_coord = coord
	is_planted = true
	is_ready = false
	is_watered = false
	growth_stage = 0
	harvests_done = 0
	
	_update_crop_visual()

func apply_water() -> void:
	if is_ready or harvests_done >= MAX_HARVESTS:
		return
	is_watered = true
	_update_crop_visual()
	print("[Cultivo] %s en %s ha sido regado." % [crop_type, tile_coord])

# Traduce la etapa numérica a tus nombres de animaciones de la imagen
func _update_crop_visual() -> void:
	var anim_name : String = crop_type
	
	match growth_stage:
		0: anim_name += "_seed"
		1: anim_name += "_grow1"
		2: anim_name += "_grow2"
		3: anim_name += "_grow3"
		4: anim_name += "_fullgrow"

	if is_watered and growth_stage < 4:
		anim_name += "_watered"

	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		# Salvaguarda por si "sugarcane_seed" o "wheat_seeds" tienen una 's' al final en tu editor
		if growth_stage == 0 and sprite.sprite_frames.has_animation(crop_type + "_seeds" + ("_watered" if is_watered else "")):
			sprite.play(crop_type + "_seeds" + ("_watered" if is_watered else ""))

func check_hourly_growth(hour: int) -> void:
	if not is_planted:
		return

	# Detener crecimiento si pasan las 6 PM
	if hour >= 18:
		if is_ready:
			_hide_interaction_prompt()
			is_ready = false
			growth_stage = 3 # Revierte a la fase anterior
			_update_crop_visual()
			print("[Cultivo] Pasaron las 6 PM. Fin de jornada.")
		return

	if harvests_done >= MAX_HARVESTS:
		return

	# No crece si no fue regado
	if not is_watered:
		print("[Cultivo] %s en %s necesita agua para seguir creciendo." % [crop_type, tile_coord])
		return

	# Si está regado, avanza una etapa
	if growth_stage < 4:
		growth_stage += 1
		_consume_water()
		
		if growth_stage == 4:
			_spawn_harvestable()
		else:
			_update_crop_visual()

func _consume_water() -> void:
	is_watered = false
	var world = get_tree().get_first_node_in_group("world")
	if world and world.grid_data.has(tile_coord):
		world.grid_data[tile_coord]["is_watered"] = false
		world._update_tile_visual(tile_coord, world.TILE_DIRT_TILLED)

func _spawn_harvestable() -> void:
	is_ready = true
	_update_crop_visual()
	
	# Forzar el chequeo para ver si el jugador está encima y mostrar el cartel [F]
	var world = get_tree().get_first_node_in_group("world")
	if world and world.has_method("_check_player_proximity_on_mature"):
		world._check_player_proximity_on_mature(tile_coord)

func show_interaction_prompt() -> void:
	if is_ready and label:
		label.visible = true

func _hide_interaction_prompt() -> void:
	if label:
		label.visible = false

func collect_harvest() -> void:
	if not is_ready:
		return

	var item_id : String = FRUIT_ITEM[crop_type]
	Inventory.add_item(item_id, 1)
	
	harvests_done += 1
	is_ready = false
	_hide_interaction_prompt()
	
	print("[Cultivo] Cosechado con éxito: %s (%d/%d)" % [item_id, harvests_done, MAX_HARVESTS])

	if harvests_done < MAX_HARVESTS:
		growth_stage = 0 # Regresa a semilla para el siguiente ciclo rápido
		_update_crop_visual()
	else:
		print("[Cultivo] Celda %s terminó sus 3 ciclos." % str(tile_coord))
		var world = get_tree().get_first_node_in_group("world")
		if world and world.has_method("free_tile_data"):
			world.free_tile_data(tile_coord)
		queue_free()
