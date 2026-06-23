extends Node2D

# =============================================================
#  PlantingSystem — Sistema de plantación integrado con Teclado
#  Adjunta este script a un Node2D en tu escena principal
# =============================================================

@export var tilemap          : TileMap      # Arrastra tu TileMap aquí
@export var planting_layer   : int = 1      # Índice de la capa plantable en tu TileMap (ej: Capa de Tierra)
@export var fruit_tree_scene : PackedScene = preload("res://Scenes/Items/Trees/fruit_trees.tscn")

# Diccionario de celdas ocupadas en la grilla: Vector2i → FruitTree
var planted_trees : Dictionary = {}

# Mapeo semilla → tipo de fruta para el árbol
const SEED_TO_FRUIT : Dictionary = {
	"apple_seed":  "apple",
	"pear_seed":   "pear",
	"orange_seed": "orange",
	"peach_seed":  "peach",
}

# =============================================================
func _unhandled_input(event: InputEvent) -> void:
	# Si el inventario está abierto en pantalla, no permitimos plantar en el mundo
	if Inventory and Inventory.visible:
		return

	# Detectamos si se presiona la tecla F (Interactuar)
	if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_F):
		# Obtenemos la posición del jugador en el mundo para saber dónde quiere plantar
		var player = get_tree().get_first_node_in_group("player") # Asegúrate de que tu Player esté en el grupo "player"
		var posicion_origen : Vector2 = global_position
		
		if player:
			posicion_origen = player.global_position

		# Convertir la posición del mapa a coordenadas de la grilla (Celdas X, Y)
		var cell : Vector2i = tilemap.local_to_map(tilemap.to_local(posicion_origen))
		
		_try_plant(cell)

# =============================================================
#  INTENTO DE PLANTACIÓN
# =============================================================
func _try_plant(cell: Vector2i) -> void:
	# 1. Miramos qué semilla tiene el jugador seleccionada con el teclado en la mano
	var selected_seed : String = Inventory.get_item_seleccionado()
	
	if selected_seed == "" or not SEED_TO_FRUIT.has(selected_seed):
		print("[PlantingSystem] No tienes ninguna semilla válida seleccionada en la mano.")
		return

	# 2. ¿La celda debajo del jugador es un terreno plantable?
	var tile_data : TileData = tilemap.get_cell_tile_data(planting_layer, cell)
	if tile_data == null:
		print("[PlantingSystem] Aquí no puedes plantar: Celda inválida en la capa ", planting_layer)
		return 

	# 3. ¿La celda ya tiene un árbol sembrado?
	if planted_trees.has(cell):
		print("[PlantingSystem] Celda ya ocupada por otro árbol: ", cell)
		return

	# 4. Verificación de stock en el inventario global
	if not Inventory.has_item(selected_seed, 1):
		print("[PlantingSystem] No te quedan unidades de: ", selected_seed)
		Inventory.limpiar_seleccion()
		return

	# 5. Todo correcto, procedemos a sembrar
	_plant_tree(cell, selected_seed)

func _plant_tree(cell: Vector2i, seed_id: String) -> void:
	# Consumir la semilla del inventario de forma definitiva
	Inventory.remove_item(seed_id, 1)

	# Instanciar el árbol en la escena
	var tree = fruit_tree_scene.instantiate()
	get_parent().add_child(tree)

	# Centrar el árbol perfectamente en el cuadro de la grilla
	var cell_center : Vector2 = tilemap.to_global(tilemap.map_to_local(cell))
	tree.global_position = cell_center

	# Extraer el tipo de fruta e iniciar el crecimiento del árbol
	var fruit_type : String = SEED_TO_FRUIT[seed_id]
	
	# Cambiado a setup_tree para que coincida con tu lógica del ciclo de día/noche
	if tree.has_method("setup_tree"):
		tree.setup_tree(fruit_type)
	elif tree.has_method("plant"):
		tree.plant(fruit_type)

	# Guardar referencia en el diccionario para bloquear esta celda
	planted_trees[cell] = tree
	
	# Si el árbol es cosechado, removido o borrado, liberamos la celda automáticamente
	tree.tree_exiting.connect(func(): 
		if planted_trees.has(cell):
			planted_trees.erase(cell)
	)

	print("[PlantingSystem] ¡Sembraste con éxito en la celda %s! Fruta asignada: %s" % [cell, fruit_type])
	
	# Si nos quedamos sin unidades de esa semilla específica, limpiamos el slot de la mano
	if not Inventory.has_item(seed_id, 1):
		Inventory.limpiar_seleccion()
