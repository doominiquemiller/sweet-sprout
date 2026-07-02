extends Node2D

# =============================================================
#  PlantingSystem — Gestor de Siembra por Tecla Interactuar (F)
# =============================================================

@export var trees_container : Node2D      # Nodo opcional para organizar tus árboles
@export var fruit_tree_scene : PackedScene # Arrastra aquí tu "fruit_trees.tscn" desde el Inspector

## Función pública llamada directamente por el TreeSpace cuando el jugador pulsa la F
## Ahora recibe el 'fruit_type' dinámicamente según la semilla del inventario
func plant_tree_at_space(target_area: Area2D, fruit_type: String) -> void:
	if not fruit_tree_scene:
		print("⚠️ [PlantingSystem] ERROR: No has asignado la escena del FruitTree.")
		return
		
	var new_tree = fruit_tree_scene.instantiate()
	
	if trees_container:
		trees_container.add_child(new_tree)
		# CORREGIDO: Usamos la posición local respecto a su contenedor para evitar desvíos en el mapa
		new_tree.position = trees_container.to_local(target_area.global_position)
	else:
		add_child(new_tree)
		new_tree.position = to_local(target_area.global_position)
		
	if new_tree.has_method("plant"):
		new_tree.plant(fruit_type)
	
	target_area.set_occupied(new_tree)
	print("[PlantingSystem] Árbol creado en posición local: ", new_tree.position)
