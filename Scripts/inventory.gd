extends CanvasLayer

# =============================================================
#  Inventory — Sistema de inventario con grilla de slots
# =============================================================

@onready var panel     : PanelContainer = $Panel
@onready var slot_grid : GridContainer  = $Panel/SlotGrid

const COLUMNS    : int = 4
const ROWS       : int = 3
const TOTAL_SLOTS: int = ROWS * COLUMNS

var items : Dictionary = {}
var slot_seleccionado_index : int = 0
var item_seleccionado : String = ""

# Iconos de cada tipo de item — TODOS COMPLETOS Y RESTAURADOS
const ITEM_ICONS : Dictionary = {
	# 🐓 Animales
	"egg":              preload("res://Assets/Objects/Egg item.png"),
	"milk":             preload("res://Assets/Objects/Milk_item.png"),
	"honey":            preload("res://Assets/Objects/Honey_item.png"),
	
	# 🍎 Frutas cosechadas (Árboles)
	"apple":            preload("res://Assets/Fruit/apple_fruit.png"),
	"orange":           preload("res://Assets/Fruit/orange_fruit.png"),
	"peach":            preload("res://Assets/Fruit/peach_fruit.png"),
	"pear":             preload("res://Assets/Fruit/pear_fruit.png"),
	
	# 🌱 Semillas de árboles
	"apple_seed":       preload("res://Assets/Seeds/apple_seed.png"),
	"orange_seed":      preload("res://Assets/Seeds/orange_seed.png"),
	"peach_seed":       preload("res://Assets/Seeds/peach_seed.png"),
	"pear_seed":        preload("res://Assets/Seeds/pear_seed.png"),
	
	# 🫐 Bayas cosechadas (Arbustos)
	"blackberry_item":  preload("res://Assets/Fruit/blackberry_item.png"),
	"blueberry_item":   preload("res://Assets/Fruit/blueberry_item.png"),
	"raspberry_item":   preload("res://Assets/Fruit/raspberry_item.png"),
	
	# 🌿 Semillas de arbustos (Bushes)
	"blackberry_seeds": preload("res://Assets/Seeds/blackberry_seeds.png"),
	"blueberry_seeds":  preload("res://Assets/Seeds/blueberry_seeds.png"),
	"raspberry_seeds":  preload("res://Assets/Seeds/raspberry_seeds.png"),

	# 🛠️ Herramientas de trabajo
	"hoe":              preload("res://Assets/Objects/hoe.png"),
	"watering_can":     preload("res://Assets/Objects/watering_can.png"),

	# 🌾 CULTIVOS (Crops) - CORREGIDO
	"wheat_seed":       preload("res://Assets/StoreIcons/semillas/wheat_seed.png"),      # Ruta corregida
	"sugarcane_seed":   preload("res://Assets/Seeds/sugarcane_seed.png"),  # Ruta corregida
	"wheat":            preload("res://Assets/Fruit/wheat_item.png"),      # CORREGIDO: antes era "wheat_item"
	"sugar_cane":       preload("res://Assets/StoreIcons/sugarcane.png"),      # CORREGIDO: antes era "sugarcane.png"
}

# IDs que son semillas — para auto-seleccionar al PlantingSystem o CropSpaces/World
const SEED_IDS : Array[String] = [
	"apple_seed", "orange_seed", "peach_seed", "pear_seed",
	"blackberry_seeds", "blueberry_seeds", "raspberry_seeds",
	"wheat_seed", "sugarcane_seed"  # CORREGIDO: añadidas ambas
]

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
	
	# =============================================================
	# 🎁 ÍTEMS INICIALES PARA PRUEBAS
	# =============================================================
	add_item("wheat_seed", 10)
	add_item("sugarcane_seed", 10)
	
	# Semillas viejas también añadidas
	add_item("blackberry_seeds", 2)
	add_item("raspberry_seeds", 2)
	add_item("blueberry_seeds", 2)
	add_item("apple_seed", 1)
	add_item("pear_seed", 1)
	add_item("peach_seed", 1)
	add_item("orange_seed", 1)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle()
		return

	if not visible:
		return

	if event.is_action_pressed("ui_left") or (event is InputEventKey and event.pressed and event.keycode == KEY_A):
		cambiar_seleccion(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right") or (event is InputEventKey and event.pressed and event.keycode == KEY_D):
		cambiar_seleccion(1)
		get_viewport().set_input_as_handled()

# =============================================================
#  NAVEGACIÓN POR TECLADO
# =============================================================
func cambiar_seleccion(direccion: int) -> void:
	slot_seleccionado_index += direccion

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

	# Actualizar item seleccionado
	if slot_seleccionado_index < _slot_order.size():
		item_seleccionado = _slot_order[slot_seleccionado_index]
	else:
		item_seleccionado = ""

	# Si el item seleccionado es una semilla, informar al PlantingSystem
	_sync_planting_system()

func _sync_planting_system() -> void:
	var planting = get_tree().get_first_node_in_group("planting_system")
	if not planting:
		return

	if item_seleccionado in SEED_IDS:
		if planting.has_method("select_seed"):
			planting.select_seed(item_seleccionado)
	else:
		if planting.has_method("deselect_seed"):
			planting.deselect_seed()

func get_item_seleccionado() -> String:
	return item_seleccionado

func limpiar_seleccion() -> void:
	item_seleccionado = ""
	_sync_planting_system()

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
