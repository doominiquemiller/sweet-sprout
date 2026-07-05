extends StaticBody2D

# =============================================================
#  Oven — Estación de Horneado Independiente en Tiempo Real conectado a Global
# =============================================================

@onready var area_2d = $Area2D
@onready var interaction_label : Label = $Label 

var player_present: bool = false
const COOKING_RECIPES = {
	"raw_bread": "bread",
	"raw_berry_cookies": "cookie",
	"raw_donuts": "donut",
	"raw_pancakes": "pancake"
}

# Estados del horno
var is_baking: bool = false
var baking_time_left: float = 0.0
var item_inside_raw: String = ""
var item_ready_to_collect: String = ""

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	
	if interaction_label:
		interaction_label.visible = false
		interaction_label.text = ""

func _process(delta: float) -> void:
	# Cuenta regresiva real del horneado
	if is_baking:
		baking_time_left -= delta
		
		if baking_time_left > 0:
			if interaction_label:
				interaction_label.text = "Horneando... %ds" % int(baking_time_left + 1.0)
				interaction_label.visible = true
		else:
			is_baking = false
			baking_time_left = 0.0
			_on_baking_finished()

func _unhandled_key_input(event: InputEvent) -> void:
	if not player_present:
		return

	# Detección al presionar la tecla F
	if event.is_pressed() and event.keycode == KEY_F:
		get_viewport().set_input_as_handled()
		
		# CASO 1: Hay un producto terminado listo para sacar
		if item_ready_to_collect != "":
			_collect_baked_item()
			return
			
		# CASO 2: El horno está cocinando actualmente
		if is_baking:
			print("[Oven] El horno está caliente, espera a que termine de hornear.")
			return
			
		# CASO 3: El horno está vacío, intentamos meter lo que el jugador lleva en la mano
		_try_start_baking()

func _try_start_baking() -> void:
	# Obtenemos el objeto que el jugador ha seleccionado de su mano en el inventario visual
	var selected_item = Inventory.get_item_seleccionado()
	
	if selected_item == "":
		print("[Oven] No tienes nada seleccionado en la mano para hornear.")
		return
		
	# Verificamos si el objeto seleccionado es una receta cruda válida para el horno
	if COOKING_RECIPES.has(selected_item):
		# Consumimos la receta cruda del inventario central Global
		var removed = Global.remove_item(selected_item, 1)
		if removed:
			item_inside_raw = selected_item
			baking_time_left = 60.0 # 1 minuto real en segundos
			is_baking = true
			
			# Limpiamos la mano del jugador ya que el objeto se introdujo al horno
			if Inventory.has_method("limpiar_seleccion"):
				Inventory.limpiar_seleccion()
			
			print("[Oven] Se ha introducido %s al horno. Iniciando 60 segundos." % selected_item)
			_update_label_state()
	else:
		print("[Oven] El objeto '%s' no se puede meter al horno." % selected_item)

func _on_baking_finished() -> void:
	# Convertimos el objeto crudo que estaba dentro a su contraparte cocinada final
	if COOKING_RECIPES.has(item_inside_raw):
		item_ready_to_collect = COOKING_RECIPES[item_inside_raw]
	
	item_inside_raw = ""
	print("[Oven] ¡Horneado completado! Listo para recoger: ", item_ready_to_collect)
	_update_label_state()

func _collect_baked_item() -> void:
	print("[Oven] Jugador recoge el producto final mediante Global: ", item_ready_to_collect)
	# Guardamos de forma segura la receta horneada en el inventario central Global
	Global.add_item(item_ready_to_collect, 1)
	
	# Reiniciamos las variables para dejar el horno libre nuevamente
	item_ready_to_collect = ""
	_update_label_state()

# Control visual dinámico del Label flotante
func _update_label_state() -> void:
	if not interaction_label:
		return
		
	if not player_present and not is_baking:
		interaction_label.visible = false
		return
		
	if is_baking:
		# La cuenta regresiva se refresca continuamente en el _process
		interaction_label.visible = true
	elif item_ready_to_collect != "":
		interaction_label.text = "[F] Sacar del horno"
		interaction_label.visible = true
	else:
		if player_present:
			var selected = Inventory.get_item_seleccionado()
			if COOKING_RECIPES.has(selected):
				interaction_label.text = "[F] Hornear mezcla"
			else:
				interaction_label.text = "Horno vacío (Lleva una mezcla cruda)"
			interaction_label.visible = true

# =============================================================
#  SEÑALES DE ENTRADA Y SALIDA DEL ÁREA
# =============================================================
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player") or body.name == "Player":
		player_present = true
		_update_label_state()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player") or body.name == "Player":
		player_present = false
		_update_label_state()
