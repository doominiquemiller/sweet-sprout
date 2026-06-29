extends Area2D

# =============================================================
#  CropSpace — Parcela para Trigo y Caña de Azúcar
#  (Sincronizada con dynamic_crop.gd)
# =============================================================

@export var dynamic_crop_scene : PackedScene = preload("res://Scenes/Items/Crops/dynamic_crop.tscn")

var is_player_inside : bool = false
var hosted_crop     : Node = null

# Diccionario de semillas válidas para esta parcela
const SEED_CONFIG : Dictionary = {
	"wheat_seeds": {"type": "wheat"},
	"sugar_cane_seeds": {"type": "sugar_cane"}
}

func _ready() -> void:
	add_to_group("crop_space")
	
	# Conexiones limpias de señales del Area2D
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)
	if body_exited.is_connected(_on_body_exited):
		body_exited.disconnect(_on_body_exited)
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not is_player_inside:
		return

	# Detecta interacción con la F o acción configurada
	if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_F):
		_handle_interaction()

# Controla si el jugador va a cosechar o a plantar
func _handle_interaction() -> void:
	# 1. SI YA HAY UN CULTIVO INSTANCIADO: Intentamos cosecharlo
	if hosted_crop != null and is_instance_valid(hosted_crop):
		# Comprobamos si el cultivo está listo para cosechar
		if hosted_crop.get("is_ready") == true:
			if hosted_crop.has_method("collect_harvest"):
				hosted_crop.collect_harvest()
			else:
				print("⚠️ [CropSpace] Error: El script del cultivo no tiene el método collect_harvest.")
		else:
			print("[CropSpace] El cultivo aún no está listo para ser cosechado.")
		return # Cortamos la ejecución aquí para que no intente plantar encima

	# 2. SI NO HAY NADA ALOJADO: Procedemos con el proceso de plantado
	_try_plant()

func _try_plant() -> void:
	var selected_seed : String = Inventory.get_item_seleccionado()
	
	if selected_seed == "" or not SEED_CONFIG.has(selected_seed):
		print("[CropSpace] Selecciona una semilla de cultivo válida (trigo o caña) en tu inventario.")
		return

	if not Inventory.has_item(selected_seed, 1):
		print("[CropSpace] No tienes más unidades de esta semilla.")
		Inventory.limpiar_seleccion()
		return

	_plant_resource(selected_seed)

func _plant_resource(seed_id: String) -> void:
	var config = SEED_CONFIG[seed_id]
	var crop_type : String = config["type"]
	
	if not dynamic_crop_scene:
		print("⚠️ [CropSpace] ERROR: No se ha asignado la escena del cultivo en el Inspector.")
		return

	Inventory.remove_item(seed_id, 1)

	var new_crop = dynamic_crop_scene.instantiate()
	add_child(new_crop)
	
	new_crop.position = Vector2.ZERO
	new_crop.z_index = 1

	# Plantamos el cultivo con su tipo y el tiempo actual de plantación
	if new_crop.has_method("plant"):
		# Obtenemos el tiempo actual del juego para calcular las animaciones
		var current_time : float = 0.0
		if GameTime.has_method("get_current_time"):
			current_time = GameTime.get_current_time()
		else:
			# Fallback: usar 6:00 AM si no podemos obtener el tiempo
			current_time = 6.0
			
		new_crop.plant(crop_type, current_time)
	else:
		print("⚠️ [CropSpace] Error: El script del cultivo no tiene el método plant.")

	hosted_crop = new_crop
	
	new_crop.tree_exiting.connect(func():
		hosted_crop = null
		print("[CropSpace] Cultivo removido. Parcela libre de nuevo.")
	)

	if not Inventory.has_item(seed_id, 1):
		Inventory.limpiar_seleccion()
		
	print("[CropSpace] ¡Cultivo de %s plantado con éxito!" % crop_type)

# =============================================================
#  DETECCIÓN DEL JUGADOR
# =============================================================
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_inside = false
