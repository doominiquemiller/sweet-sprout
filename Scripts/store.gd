extends Control

@onready var grid : GridContainer = $ScrollContainer/GridContainer
@export var store_item : PackedScene

var store_data: Array = [
	{"item_id": "apple_seed", "price": 40, "icon_path": "res://Assets/Seeds/apple_seed.png", "label1": "Semilla de Manzana", "label2": "40 coins", "custom_button_text": "Buy"},
	{"item_id": "orange_seed", "price": 40, "icon_path": "res://Assets/Seeds/orange_seed.png", "label1": "Semilla de Naranja", "label2": "40 coins", "custom_button_text": "Buy"},
	{"item_id": "peach_seed", "price": 45, "icon_path": "res://Assets/Seeds/peach_seed.png", "label1": "Semilla de Melocotón", "label2": "45 coins", "custom_button_text": "Buy"},
	{"item_id": "pear_seed", "price": 40, "icon_path": "res://Assets/Seeds/pear_seed.png", "label1": "Semilla de Pera", "label2": "40 coins", "custom_button_text": "Buy"},
	{"item_id": "wheat_seed", "price": 6, "icon_path": "res://Assets/StoreIcons/semillas/wheat_seed.png", "label1": "Semilla de Trigo", "label2": "6 coins", "custom_button_text": "Buy"},
	{"item_id": "sugarcane_seed", "price": 20, "icon_path": "res://Assets/Seeds/sugarcane_seed.png", "label1": "Semilla de Caña de Azúcar", "label2": "20 coins", "custom_button_text": "Buy"},
	{"item_id": "milk", "price": 15, "icon_path": "res://Assets/Objects/Milk_item.png", "label1": "Leche", "label2": "15 coins", "custom_button_text": "Buy"},
	{"item_id": "egg", "price": 8, "icon_path": "res://Assets/Objects/Egg item.png", "label1": "Huevo", "label2": "8 coins", "custom_button_text": "Buy"},
	{"item_id": "honey", "price": 18, "icon_path": "res://Assets/Objects/Honey_item.png", "label1": "Miel", "label2": "18 coins", "custom_button_text": "Buy"}
]

func _ready() -> void:
	print("=== TIENDA INICIADA ===")
	setup_store()

func setup_store() -> void:
	for child in grid.get_children():
		child.queue_free()
	
	await get_tree().process_frame

	var id = 0
	for data in store_data:
		var temp = store_item.instantiate()
		grid.add_child(temp)
		temp.item_buy_pressed.connect(_on_item_buy_pressed)
		temp.setup(data, id)
		id += 1

func _on_item_buy_pressed(id: int) -> void:
	if id < 0 or id >= store_data.size():
		return

	var data = store_data[id]
	var item_id = data["item_id"]
	var price = data["price"]
	
	print("Intentando comprar: ", item_id, " | Precio: ", price, " | Dinero actual: ", Global.get_money())

	# CORREGIDO: spend_money comprueba y descuenta directamente. Evitamos ifs redundantes.
	if Global.spend_money(price):
		Global.add_item(item_id, 1)
		print("[ÉXITO] Comprado: ", item_id, " | Nuevo saldo: ", Global.get_money())
	else:
		print("[FRACASO] Fondos insuficientes para comprar ", item_id)

func _on_texture_button_pressed() -> void:
	queue_free()
