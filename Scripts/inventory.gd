extends CanvasLayer

@onready var panel : PanelContainer = $Panel
@onready var slot_grid : GridContainer = $Panel/SlotGrid

const COLUMNS : int = 4
const ROWS : int = 3
const TOTAL_SLOTS : int = ROWS * COLUMNS

var slot_seleccionado_index : int = 0
var item_seleccionado : String = ""
var _slot_nodes : Array = []

const ITEM_ICONS : Dictionary = {
	"egg": preload("res://Assets/Objects/Egg item.png"),
	"milk": preload("res://Assets/Objects/Milk_item.png"),
	"honey": preload("res://Assets/Objects/Honey_item.png"),
	"apple": preload("res://Assets/Fruit/apple_fruit.png"),
	"orange": preload("res://Assets/Fruit/orange_fruit.png"),
	"peach": preload("res://Assets/Fruit/peach_fruit.png"),
	"pear": preload("res://Assets/Fruit/pear_fruit.png"),
	"apple_seed": preload("res://Assets/Seeds/apple_seed.png"),
	"orange_seed": preload("res://Assets/Seeds/orange_seed.png"),
	"peach_seed": preload("res://Assets/Seeds/peach_seed.png"),
	"pear_seed": preload("res://Assets/Seeds/pear_seed.png"),
	"blackberry_item": preload("res://Assets/Fruit/blackberry_item.png"),
	"blueberry_item": preload("res://Assets/Fruit/blueberry_item.png"),
	"raspberry_item": preload("res://Assets/Fruit/raspberry_item.png"),
	"blackberry_seeds": preload("res://Assets/Seeds/blackberry_seeds.png"),
	"blueberry_seeds": preload("res://Assets/Seeds/blueberry_seeds.png"),
	"raspberry_seeds": preload("res://Assets/Seeds/raspberry_seeds.png"),
	"hoe": preload("res://Assets/Objects/hoe.png"),
	"watering_can": preload("res://Assets/Objects/watering_can.png"),
	"wheat_seed": preload("res://Assets/StoreIcons/semillas/wheat_seed.png"),
	"sugarcane_seed": preload("res://Assets/Seeds/sugarcane_seed.png"),
	"wheat": preload("res://Assets/Fruit/wheat_item.png"),
	"sugar_cane": preload("res://Assets/StoreIcons/sugarcane.png"),
	"raw_bread": preload("res://Assets/raw_recipes/raw_bread.png"),
	"raw_berry_cookies": preload("res://Assets/raw_recipes/raw_berry_cookies.png"),
	"raw_donuts": preload("res://Assets/raw_recipes/raw_donuts.png"),
	"raw_pancakes": preload("res://Assets/raw_recipes/raw_pancakes.png"),
	"yeast": preload("res://Assets/StoreIcons/yeast.png"),
	"flour": preload("res://Assets/StoreIcons/flour.png"),
	"butter": preload("res://Assets/StoreIcons/butter.png"),
	"oil": preload("res://Assets/StoreIcons/oil.png"),
	"bread": preload("res://Assets/Bakery/recetas/bread.png"),
	"cookie": preload("res://Assets/Bakery/recetas/cookie.png"),
	"donut": preload("res://Assets/Bakery/recetas/donut.png"),
	"pancake": preload("res://Assets/Bakery/recetas/pancake.png"),
}

const SEED_IDS : Array[String] = [
	"apple_seed", "orange_seed", "peach_seed", "pear_seed",
	"blackberry_seeds", "blueberry_seeds", "raspberry_seeds",
	"wheat_seed", "sugarcane_seed"
]

func _ready() -> void:
	visible = false
	slot_grid.columns = COLUMNS
	_slot_nodes = slot_grid.get_children()
	
	for slot in _slot_nodes:
		slot.set_empty()
	
	# Conectar señal de actualización del inventario
	Global.inventory_updated.connect(_refresh_slots)
	
	# Items iniciales de prueba
	Global.add_item("wheat_seed", 5)
	Global.add_item("sugarcane_seed", 5)
	Global.add_item("blackberry_seeds", 2)
	Global.add_item("raspberry_seeds", 2)
	Global.add_item("blueberry_seeds", 2)
	Global.add_item("apple_seed", 1)
	Global.add_item("pear_seed", 1)
	Global.add_item("peach_seed", 1)
	Global.add_item("orange_seed", 1)
	Global.add_item("yeast", 1)
	Global.add_item("flour", 1)
	Global.add_item("milk", 1)
	Global.add_item("bread", 1)
	
	_refresh_slots()

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

func cambiar_seleccion(direccion: int) -> void:
	slot_seleccionado_index += direccion

	if slot_seleccionado_index >= _slot_nodes.size():
		slot_seleccionado_index = 0
	elif slot_seleccionado_index < 0:
		slot_seleccionado_index = _slot_nodes.size() - 1

	_actualizar_marcos_visuales()

func _actualizar_marcos_visuales() -> void:
	var order = Global.get_inventory_order()
	for i in range(_slot_nodes.size()):
		var slot = _slot_nodes[i]
		if slot.has_method("marcar_como_seleccionado"):
			slot.marcar_como_seleccionado(i == slot_seleccionado_index)

	if slot_seleccionado_index < order.size():
		item_seleccionado = order[slot_seleccionado_index]
	else:
		item_seleccionado = ""

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

func toggle() -> void:
	visible = not visible
	if visible:
		_actualizar_marcos_visuales()

func open() -> void:
	visible = true
	_actualizar_marcos_visuales()

func close() -> void:
	visible = false

func _refresh_slots() -> void:
	var inventory = Global.get_inventory()
	var order = Global.get_inventory_order()
	
	for i in range(_slot_nodes.size()):
		var slot = _slot_nodes[i]
		if i < order.size():
			var item_id : String = order[i]
			var icon : Texture2D = ITEM_ICONS.get(item_id, null)
			slot.mi_item_id = item_id
			slot.set_item(icon, inventory[item_id])
		else:
			slot.mi_item_id = ""
			slot.set_empty()

	_actualizar_marcos_visuales()
