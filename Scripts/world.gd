extends Node2D

# Cambiamos @onready estricto por @export para que puedas arrastrarlo desde el inspector
@export var dirt_tilemap_layer : TileMapLayer 

@export var dynamic_crop_scene : PackedScene = preload("res://Scenes/dynamic_crop.tscn")

var grid_data : Dictionary = {}
var last_player_coord : Vector2i = Vector2i(-999, -999)

const SEED_CONFIG : Dictionary = {
	"wheat_seed":     {"type": "wheat"},
	"sugarcane_seed": {"type": "sugarcane"}
}

# Coordenadas del Atlas en tu TileSet
const TILE_DIRT_NORMAL   := Vector2i(0, 0)
const TILE_DIRT_TILLED   := Vector2i(1, 0)
const TILE_DIRT_WATERED  := Vector2i(2, 0)

func _ready() -> void:
	add_to_group("world")
	
	# MECANISMO DE SEGURIDAD AUTOMÁTICO: 
	# Si no arrastraste el nodo en el inspector, intentamos buscarlo por tipo en la escena
	if not dirt_tilemap_layer:
		var found_layer = find_child("*DirtLayer*", true, false)
		if found_layer and found_layer is TileMapLayer:
			dirt_tilemap_layer = found_layer
		else:
			# Si falla, busca el primer TileMapLayer que encuentre como plan C
			for child in get_children():
				if child is TileMapLayer:
					dirt_tilemap_layer = child
					break
					
	if not dirt_tilemap_layer:
		push_error("[ERROR CRÍTICO] world.gd: ¡No se encontró ningún nodo TileMapLayer en la escena! Asegúrate de asignarlo en el Inspector.")

func _process(_delta: float) -> void:
	_monitor_player_movement()

func _monitor_player_movement() -> void:
	# Si el nodo no existe, salimos pacíficamente en lugar de romper el juego
	if not dirt_tilemap_layer: 
		return
		
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
		
	var current_coord : Vector2i = dirt_tilemap_layer.local_to_map(dirt_tilemap_layer.to_local(player.global_position))
	
	if current_coord != last_player_coord:
		if grid_data.has(last_player_coord) and is_instance_valid(grid_data[last_player_coord]["crop_node"]):
			grid_data[last_player_coord]["crop_node"]._hide_interaction_prompt()
			
		if grid_data.has(current_coord) and is_instance_valid(grid_data[current_coord]["crop_node"]):
			grid_data[current_coord]["crop_node"].show_interaction_prompt()
			
		last_player_coord = current_coord

func _check_player_proximity_on_mature(coord: Vector2i) -> void:
	if coord == last_player_coord and grid_data.has(coord) and is_instance_valid(grid_data[coord]["crop_node"]):
		grid_data[coord]["crop_node"].show_interaction_prompt()

func _unhandled_input(event: InputEvent) -> void:
	# Evitamos ejecutar interacciones si la capa de suelo falló al cargar
	if not dirt_tilemap_layer: 
		return
		
	if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_F):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var cell_coord : Vector2i = dirt_tilemap_layer.local_to_map(dirt_tilemap_layer.to_local(player.global_position))
			_handle_tool_and_crop_interaction(cell_coord)

func _handle_tool_and_crop_interaction(coord: Vector2i) -> void:
	if dirt_tilemap_layer.get_cell_source_id(coord) == -1:
		return

	if not grid_data.has(coord):
		grid_data[coord] = {"crop_node": null, "is_tilled": false, "is_watered": false}

	var cell = grid_data[coord]
	var active_tool : String = Inventory.get_item_seleccionado()

	# 1. HERRAMIENTA: AZADA
	if active_tool == "hoe":
		if not cell["is_tilled"]:
			cell["is_tilled"] = true
			_update_tile_visual(coord, TILE_DIRT_TILLED)
			print("[Mundo] Celda labrada en: ", coord)
		return

	# 2. HERRAMIENTA: REGADERA
	if active_tool == "watering_can":
		if cell["is_tilled"] and not cell["is_watered"]:
			cell["is_watered"] = true
			_update_tile_visual(coord, TILE_DIRT_WATERED)
			if is_instance_valid(cell["crop_node"]):
				cell["crop_node"].apply_water()
			print("[Mundo] Celda regada en: ", coord)
		return

	# 3. ACCIÓN: COSECHAR
	if is_instance_valid(cell["crop_node"]):
		var crop_node = cell["crop_node"]
		if crop_node.is_ready:
			crop_node.collect_harvest()
		else:
			print("[Mundo] El cultivo aún se encuentra en desarrollo.")
		return

	# 4. ACCIÓN: PLANTAR SEMILLA
	if cell["is_tilled"] and cell["crop_node"] == null:
		_try_plant_on_tile(coord)

func _try_plant_on_tile(coord: Vector2i) -> void:
	var selected_seed : String = Inventory.get_item_seleccionado()
	
	if selected_seed == "" or not SEED_CONFIG.has(selected_seed):
		print("[Mundo] Selecciona una semilla de cultivo válida.")
		return

	if not Inventory.has_item(selected_seed, 1):
		print("[Mundo] No tienes suficientes semillas.")
		Inventory.limpiar_seleccion()
		return

	Inventory.remove_item(selected_seed, 1)
	var plant_type : String = SEED_CONFIG[selected_seed]["type"]

	var new_crop = dynamic_crop_scene.instantiate()
	dirt_tilemap_layer.add_child(new_crop)
	new_crop.global_position = dirt_tilemap_layer.to_global(dirt_tilemap_layer.map_to_local(coord))
	new_crop.init_crop(plant_type, coord)

	if grid_data[coord]["is_watered"]:
		new_crop.apply_water()

	grid_data[coord]["crop_node"] = new_crop
	
	if not Inventory.has_item(selected_seed, 1):
		Inventory.limpiar_seleccion()

func _update_tile_visual(coord: Vector2i, tile_atlas_coord: Vector2i) -> void:
	if not dirt_tilemap_layer: return
	var source_id = dirt_tilemap_layer.get_cell_source_id(coord)
	dirt_tilemap_layer.set_cell(coord, source_id, tile_atlas_coord)

func free_tile_data(coord: Vector2i) -> void:
	if grid_data.has(coord):
		grid_data[coord]["crop_node"] = null
		grid_data[coord]["is_watered"] = false
		_update_tile_visual(coord, TILE_DIRT_TILLED)
		print("[Huerto] Ciclo completado. Celda arada reestablecida: ", coord)
