extends Node2D

# =============================================================
#  PlantingSystem — Gestor de Siembra sin TileMaps
# =============================================================

@export var trees_container : Node2D      # Nodo opcional en tu escena para organizar tus árboles
@export var fruit_tree_scene : PackedScene # Arrastra aquí tu "fruit_trees.tscn" desde el Inspector

func _unhandled_input(event: InputEvent) -> void:
	# Captura el clic del ratón (Verifica si el nombre "click_izquierdo" coincide con tus Inputs)
	if event.is_action_pressed("click_izquierdo"):
		var mouse_pos = get_global_mouse_position()
		_try_plant_on_area(mouse_pos)

func _try_plant_on_area(world_pos: Vector2) -> void:
	# Usamos el motor de físicas de Godot para ver si el clic tocó un área interactiva
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_areas = true  # Esto nos permite detectar los Area2D TreeSpace
	
	var results = space_state.intersect_point(query)
	
	for result in results:
		var area = result.collider
		
		# Validamos que el nodo clickeado sea un espacio de cultivo libre
		if area.is_in_group("tree_space") and area.has_method("is_empty") and area.is_empty():
			_spawn_tree(area, world_pos)
			break # Salimos para sembrar solo un árbol a la vez

func _spawn_tree(target_area: Area2D, spawn_pos: Vector2) -> void:
	if not fruit_tree_scene:
		print("⚠️ [PlantingSystem] ERROR: No has asignado la escena del FruitTree en el Inspector.")
		return
		
	# Instanciamos el árbol de forma dinámica en la posición del clic
	var new_tree = fruit_tree_scene.instantiate()
	
	if trees_container:
		trees_container.add_child(new_tree)
	else:
		add_child(new_tree)
		
	new_tree.global_position = spawn_pos
	
	# Definimos el tipo de fruta (Vincula esto con el item seleccionado de tu jugador o mano)
	var selected_fruit = "apple" 
	new_tree.plant(selected_fruit)
	
	# Le notificamos al TreeSpace que ahora está ocupado por este nodo
	target_area.set_occupied(new_tree)
	print("[PlantingSystem] Árbol creado con éxito en: ", spawn_pos)
