extends CanvasLayer

# =============================================================
#  Inventory — Sistema de inventario con grilla de slots
#  Los 12 slots ya están instanciados manualmente en el editor
#  dentro de SlotGrid — este script NO crea slots nuevos.
# =============================================================

@onready var panel     : PanelContainer = $Panel
@onready var slot_grid : GridContainer  = $Panel/SlotGrid

const COLUMNS    : int = 4
const ROWS       : int = 3
const TOTAL_SLOTS: int = ROWS * COLUMNS

var items : Dictionary = {}

const ITEM_ICONS : Dictionary = {
	"egg": preload("res://Assets/Objects/Egg item.png"),
}

var _slot_order : Array[String] = []
var _slot_nodes : Array = []

signal item_added(item_id: String, amount: int)
signal inventory_changed

# =============================================================
func _ready() -> void:
	visible = false
	slot_grid.columns = COLUMNS

	# Tomamos los slots que YA existen en la escena (instanciados a mano)
	# en vez de crear nuevos — esto evita la duplicación
	_slot_nodes = slot_grid.get_children()

	for slot in _slot_nodes:
		slot.set_empty()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle()

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

func open() -> void:
	visible = true

func close() -> void:
	visible = false

# =============================================================
func _refresh_slots() -> void:
	for i in range(_slot_nodes.size()):
		var slot = _slot_nodes[i]
		if i < _slot_order.size():
			var item_id : String = _slot_order[i]
			var icon : Texture2D = ITEM_ICONS.get(item_id, null)
			slot.set_item(icon, items[item_id])
		else:
			slot.set_empty()
