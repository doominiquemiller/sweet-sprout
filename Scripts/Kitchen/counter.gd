extends StaticBody2D

# =============================================================
#  Showcase — Vitrina de Exhibición con Frames Dinámicos
# =============================================================

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d = $Area2D

# ⚠️ NOTA: Recuerda añadir un nodo Label como hijo de tu vitrina en la escena
@onready var interaction_label : Label = $Label

var player_present: bool = false

# Lista de productos válidos que se pueden exhibir (recetas finales del horno)
const VALID_PRODUCTS = ["bread", "berry_cookies", "donuts", "pancakes"]

# Diccionario interno para saber qué hay guardado en la vitrina y cuántos
var stocked_items: Dictionary = {
	"bread": 0,
	"cookies": 0,
	"donuts": 0,
	"pancakes": 0
}

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	
	# Aseguramos el estado inicial en vacío
	animated_sprite.animation = "default"
	animated_sprite.frame = 0
	
	if interaction_label:
		interaction_label.visible = false
		interaction_label.text = ""

func _unhandled_key_input(event: InputEvent) -> void:
	if not player_present:
		return

	if event.is_pressed() and event.keycode == KEY_F:
		get_viewport().set_input_as_handled()
		
		var selected_item = Inventory.get_item_seleccionado()
		
		# CASO 1: El jugador tiene un producto horneado válido en la mano -> Dejar en vitrina
		if selected_item in VALID_PRODUCTS:
			_deposit_item(selected_item)
		# CASO 2: El jugador no tiene un producto válido en mano -> Intentar retirar/comprar producto
		else:
			_try_retire_item()

func _deposit_item(item_id: String) -> void:
	var removed = Inventory.remove_item(item_id, 1)
	if removed:
		stocked_items[item_id] += 1
		print("[Vitrina] Añadido: ", item_id, ". Total en vitrina: ", stocked_items[item_id])
		
		# Limpiamos la mano del jugador si ya no le quedan unidades de ese ítem
		if not Inventory.has_item(item_id, 1):
			Inventory.limpiar_seleccion()
			
		_update_showcase_state()

func _try_retire_item() -> void:
	# Buscamos el primer ítem que tenga existencias en la vitrina para entregárselo al jugador
	for item_id in stocked_items.keys():
		if stocked_items[item_id] > 0:
			stocked_items[item_id] -= 1
			Inventory.add_item(item_id, 1)
			print("[Vitrina] Retirado: ", item_id, ". Quedan: ", stocked_items[item_id])
			_update_showcase_state()
			return
			
	print("[Vitrina] La vitrina está completamente vacía, no hay nada que retirar.")

func _get_total_items_count() -> int:
	var total = 0
	for count in stocked_items.values():
		total += count
	return total

func _update_showcase_state() -> void:
	var total_stored = _get_total_items_count()
	
	# Cambiar dinámicamente el frame según la cantidad de objetos
	if total_stored > 0:
		animated_sprite.frame = 1  # Frame con dulces (imagen image_a2772a.png)
	else:
		animated_sprite.frame = 0  # Frame vacío (imagen image_a2772a.png)
		
	_update_label_text(total_stored)

func _update_label_text(total_stored: int) -> void:
	if not interaction_label:
		return
		
	if not player_present:
		interaction_label.visible = false
		return
		
	# Generamos la lista de lo que contiene la vitrina de forma limpia
	var display_text = ""
	
	if total_stored > 0:
		display_text += "--- VITRINA ---\n"
		if stocked_items["bread"] > 0: display_text += "Pan: %d\n" % stocked_items["bread"]
		if stocked_items["berry_cookies"] > 0: display_text += "Galletas: %d\n" % stocked_items["berry_cookies"]
		if stocked_items["donuts"] > 0: display_text += "Donas: %d\n" % stocked_items["donuts"]
		if stocked_items["pancakes"] > 0: display_text += "Pancakes: %d\n" % stocked_items["pancakes"]
		display_text += "[F] Retirar producto"
	else:
		display_text = "Vitrina Vacía\n[F] Colocar producto listo de la mano"
		
	interaction_label.text = display_text
	interaction_label.visible = true

# =============================================================
#  DETECCIÓN DE AREA
# =============================================================
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player") or body.name == "Player":
		player_present = true
		_update_showcase_state()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player") or body.name == "Player":
		player_present = false
		if interaction_label:
			interaction_label.visible = false
