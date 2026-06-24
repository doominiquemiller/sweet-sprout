extends CanvasLayer

# =============================================================
#  Inventory — Sistema de inventario con grilla de slots
#  Los slots ya están instanciados manualmente en el editor
#  dentro de SlotGrid — este script NO crea slots nuevos.
# =============================================================

@onready var panel     : PanelContainer = $Panel
@onready var slot_grid : GridContainer  = $Panel/SlotGrid

const COLUMNS    : int = 4
const ROWS       : int = 3
const TOTAL_SLOTS: int = ROWS * COLUMNS

var items : Dictionary = {}
var slot_seleccionado_index : int = 0
var item_seleccionado : String = ""

# Iconos de cada tipo de item
const ITEM_ICONS : Dictionary = {
	"egg":  preload("res://Assets/Objects/Egg item.png"),
	"milk": preload("res://Assets/Objects/Milk_item.png"),
	"apple_seed":  preload("res://Assets/Seeds/apple_seed.png"), 
	"orange_seed": preload("res://Assets/Seeds/orange_seed.png"),
	"peach_seed":  preload("res://Assets/Seeds/peach_seed.png"),
	"pear_seed":   preload("res://Assets/Seeds/pear_seed.png"),
}

var _slot_order : Array[String] = []
var _slot_nodes : Array = []

signal item_added(item_id: String, amount: int)
signal inventory_changed

# =============================================================
func _ready() -> void:
	visible = false
	slot_grid.columns = COLUMNS

	_slot_nodes = slot_grid.get_children()
	for slot in _slot_nodes:
		slot.set_empty()
		
	_actualizar_marcos_visuales()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle()
		return
		
	# Si el inventario no está visible, ignoramos la navegación A/D del menú
	if not visible:
		return
		
	# Detección de teclas A (Izquierda) y D (Derecha)
	if event.is_action_pressed("ui_left") or (event is InputEventKey and event.pressed and event.keycode == KEY_A):
		cambiar_seleccion(-1)
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("ui_right") or (event is InputEventKey and event.pressed and event.keycode == KEY_D):
		cambiar_seleccion(1)
		get_viewport().set_input_as_handled()

# =============================================================
#  Navegación por Teclado
# =============================================================
func cambiar_seleccion(direccion: int) -> void:
	slot_seleccionado_index += direccion
	
	# Bucle circular de los 12 slots (0 al 11)
	if slot_seleccionado_index >= _slot_nodes.size():
		slot_seleccionado_index = 0
	elif slot_seleccionado_index < 0:
		slot_seleccionado_index = _slot_nodes.size() - 1
		
	_actualizar_marcos_visuales()

func _actualizar_marcos_visuales() -> void:
	for i in range(_slot_nodes.size()):
		var slot = _slot_nodes[i]
		if slot.has_method("marcar_como_seleccionado"):
			slot.marcar_como_seleccionado(i == slot_seleccionado_index)
			
	# Actualizar el ID del ítem apuntado por el índice de navegación
	if slot_seleccionado_index < _slot_order.size():
		item_seleccionado = _slot_order[slot_seleccionado_index]
	else:
		item_seleccionado = ""

func get_item_seleccionado() -> String:
	return item_seleccionado

func limpiar_seleccion() -> void:
	item_seleccionado = ""

# =============================================================
#  API PÚBLICA
# =============================================================
func add_item(item_id: String, amount: int = 1) -> void:
	if not items.has(item_id):
		items[item_id] = 0
		_slot_order.append(item_id)

	items[item_id] += amount
	_refresh_slots()
	emit_signal("item_added", item_id, amount)
	emit_signal("inventory_changed")

func remove_item(item_id: String, amount: int = 1) -> bool:
	if not items.has(item_id) or items[item_id] < amount:
		return false
	items[item_id] -= amount
	if items[item_id] <= 0:
		items.erase(item_id)
		_slot_order.erase(item_id)
	_refresh_slots()
	emit_signal("inventory_changed")
	return true

func get_item_count(item_id: String) -> int:
	return items.get(item_id, 0)

func has_item(item_id: String, amount: int = 1) -> bool:
	return get_item_count(item_id) >= amount

func toggle() -> void:
	visible = not visible
	if visible:
		_actualizar_marcos_visuales()

func open() -> void:
	visible = true
	_actualizar_marcos_visuales()

func close() -> void:
	visible = false

# =============================================================
func _refresh_slots() -> void:
	for i in range(_slot_nodes.size()):
		var slot = _slot_nodes[i]
		if i < _slot_order.size():
			var item_id : String = _slot_order[i]
			var icon : Texture2D = ITEM_ICONS.get(item_id, null)
			slot.mi_item_id = item_id
			slot.set_item(icon, items[item_id])
		else:
			slot.mi_item_id = ""
			slot.set_empty()
			
	_actualizar_marcos_visuales()
