extends StaticBody2D

# =============================================================
#  SellBaul — Sistema de Venta de Ingredientes conectado a ClockUI
# =============================================================

@onready var area_2d = $Area2D
@onready var interaction_label : Label = $Label

var player_present: bool = false

const ITEM_PRICES = {
	"apple": 25,
	"pear": 25,
	"orange": 25,
	"peach": 25,
	"blueberry_item": 20,
	"blackberry_item": 20,
	"raspberry_item": 20,
	"wheat": 15,
	"sugar_cane": 15,
	"egg": 5,
	"milk": 10,
	"honey": 10
}

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	
	if interaction_label:
		interaction_label.visible = false
		interaction_label.text = ""

func _unhandled_key_input(event: InputEvent) -> void:
	if not player_present:
		return

	if event.is_pressed() and event.keycode == KEY_F:
		get_viewport().set_input_as_handled()
		_try_sell_item()

func _try_sell_item() -> void:
	var selected_item = Inventory.get_item_seleccionado()
	
	if selected_item == "":
		_show_temporary_message("¡Mano vacía!\nSelecciona algo para vender.")
		return
		
	if ITEM_PRICES.has(selected_item):
		var price = ITEM_PRICES[selected_item]
		
		# 1. Intentamos quitar el objeto del inventario del jugador
		var removed = Inventory.remove_item(selected_item, 1)
		if removed:
			# 2. Buscamos el nodo de la interfaz que contiene el script ClockUI
			var clock_ui = _find_clock_ui_node(get_tree().current_scene)
			
			if clock_ui and clock_ui.has_method("add_money"):
				clock_ui.add_money(price) # 👈 Aquí le suma el dinero real a tu UI
				print("[Baul] Dinero enviado exitosamente a ClockUI.")
			else:
				# Alternativa por si usas un Autoload/Singleton global
				if Inventory.has_method("add_money"):
					Inventory.add_money(price)
				print("[⚠️ Alerta] No se encontró ClockUI en la escena, usando fallback.")

			print("[Baul] Vendido 1x %s por %d monedas." % [selected_item, price])
			
			if not Inventory.has_item(selected_item, 1):
				Inventory.limpiar_seleccion()
				
			_show_temporary_message("+%d Monedas!" % price)
	else:
		_show_temporary_message("Este objeto no se\npuede vender aquí.")

# Función recursiva auxiliar para encontrar automáticamente tu nodo ClockUI en la escena activa
func _find_clock_ui_node(current_node: Node) -> Node:
	if current_node.get_script() and "money" in current_node and current_node.has_method("add_money"):
		return current_node
	for child in current_node.get_children():
		var found = _find_clock_ui_node(child)
		if found:
			return found
	return null

func _show_temporary_message(msg: String) -> void:
	if not interaction_label: return
	interaction_label.text = msg
	get_tree().create_timer(1.5).timeout.connect(_update_label_state)

func _update_label_state() -> void:
	if not interaction_label:
		return
		
	if not player_present:
		interaction_label.visible = false
		return
		
	var selected = Inventory.get_item_seleccionado()
	
	if ITEM_PRICES.has(selected):
		interaction_label.text = "[F] Vender 1x %s\nValor: %d Monedas" % [selected.capitalize(), ITEM_PRICES[selected]]
	else:
		interaction_label.text = "Baúl de Ventas\n(Sostén un ingrediente en la mano)"
		
	interaction_label.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player") or body.name == "Player":
		player_present = true
		_update_label_state()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player") or body.name == "Player":
		player_present = false
		if interaction_label:
			interaction_label.visible = false
