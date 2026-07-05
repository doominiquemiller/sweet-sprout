extends StaticBody2D

# =============================================================
#  SellBaul — Sistema de Venta de Ingredientes conectado a Global
# =============================================================

@onready var area_2d = $Area2D
@onready var interaction_label : Label = $Label
@onready var sonido_venta: AudioStreamPlayer2D = $SonidoVenta

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
		
		# 1. Intentamos quitar el objeto usando el inventario global (o tu script local Inventory si maneja la mano)
		var removed = Global.remove_item(selected_item, 1)
		if removed:
			# 2. Sumamos el dinero directamente al Autoload Global
			Global.add_money(price)
			
			# 3. Reproducimos el efecto de sonido de la venta
			if sonido_venta:
				sonido_venta.play()

			print("[Baul] Vendido 1x %s por %d monedas usando Global." % [selected_item, price])
			
			# Sincronizamos la limpieza de la mano si tu script de inventario visual lo requiere
			if not Global.has_item(selected_item, 1) and Inventory.has_method("limpiar_seleccion"):
				Inventory.limpiar_seleccion()
				
			_show_temporary_message("+%d Monedas!" % price)
	else:
		_show_temporary_message("Este objeto no se\npuede vender aquí.")

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
