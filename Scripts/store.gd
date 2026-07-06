extends Control

@onready var grid : GridContainer = $ScrollContainer/GridContainer
@export var store_item : PackedScene

var store_data: Array = [
	# Ingredientes
	{"item_id":"egg",              "price":10, "icon_path":"res://Assets/StoreIcons/Egg_item.png",                "label1":"Huevo",                  "label2":"10 coins", "custom_button_text":"Comprar"},
	{"item_id":"milk",             "price":15, "icon_path":"res://Assets/StoreIcons/Milk_item.png",               "label1":"Leche",                  "label2":"15 coins", "custom_button_text":"Comprar"},
	{"item_id":"flour",            "price":20, "icon_path":"res://Assets/StoreIcons/flour.png",                   "label1":"Harina",                 "label2":"20 coins", "custom_button_text":"Comprar"},
	{"item_id":"butter",           "price":25, "icon_path":"res://Assets/StoreIcons/butter.png",                  "label1":"Mantequilla",            "label2":"25 coins", "custom_button_text":"Comprar"},
	{"item_id":"honey",            "price":22, "icon_path":"res://Assets/StoreIcons/honey.png",                   "label1":"Miel",                   "label2":"22 coins", "custom_button_text":"Comprar"},
	{"item_id":"oil",              "price":18, "icon_path":"res://Assets/StoreIcons/oil.png",                     "label1":"Aceite",                 "label2":"18 coins", "custom_button_text":"Comprar"},
	{"item_id":"yeast",            "price":15, "icon_path":"res://Assets/StoreIcons/yeast.png",                   "label1":"Levadura",               "label2":"15 coins", "custom_button_text":"Comprar"},
	{"item_id":"sugar_cane",       "price":12, "icon_path":"res://Assets/StoreIcons/sugarcane.png",               "label1":"Caña de azúcar",         "label2":"12 coins", "custom_button_text":"Comprar"},

	# Cultivos
	{"item_id":"wheat_seed",       "price":8,  "icon_path":"res://Assets/StoreIcons/semillas/wheat_seed.png",     "label1":"Semilla de trigo",       "label2":"8 coins",  "custom_button_text":"Comprar"},
	{"item_id":"wheat",            "price":12, "icon_path":"res://Assets/StoreIcons/frutos/wheat.png",            "label1":"Trigo",                  "label2":"12 coins", "custom_button_text":"Comprar"},

	# Árboles
	{"item_id":"apple_seed",       "price":40, "icon_path":"res://Assets/StoreIcons/semillas/apple_seed.png",     "label1":"Semilla de manzana",     "label2":"40 coins", "custom_button_text":"Comprar"},
	{"item_id":"apple",            "price":20, "icon_path":"res://Assets/StoreIcons/frutos/apple.png",            "label1":"Manzana",                "label2":"20 coins", "custom_button_text":"Comprar"},

	{"item_id":"orange_seed",      "price":40, "icon_path":"res://Assets/StoreIcons/semillas/orange_seed.png",    "label1":"Semilla de naranja",     "label2":"40 coins", "custom_button_text":"Comprar"},
	{"item_id":"orange",           "price":20, "icon_path":"res://Assets/StoreIcons/frutos/orange.png",           "label1":"Naranja",                "label2":"20 coins", "custom_button_text":"Comprar"},

	{"item_id":"pear_seed",        "price":40, "icon_path":"res://Assets/StoreIcons/semillas/pear_seed.png",      "label1":"Semilla de pera",        "label2":"40 coins", "custom_button_text":"Comprar"},
	{"item_id":"pear",             "price":20, "icon_path":"res://Assets/StoreIcons/frutos/pear.png",             "label1":"Pera",                   "label2":"20 coins", "custom_button_text":"Comprar"},

	{"item_id":"peach_seed",       "price":45, "icon_path":"res://Assets/StoreIcons/semillas/peach_seed.png",     "label1":"Semilla de melocotón",   "label2":"45 coins", "custom_button_text":"Comprar"},
	{"item_id":"peach",            "price":25, "icon_path":"res://Assets/StoreIcons/frutos/peach.png",            "label1":"Melocotón",              "label2":"25 coins", "custom_button_text":"Comprar"},

	# Berries
	{"item_id":"blackberry_seeds", "price":22, "icon_path":"res://Assets/StoreIcons/semillas/blackberry_seed.png","label1":"Semilla de zarzamora",   "label2":"22 coins", "custom_button_text":"Comprar"},
	{"item_id":"blackberry_item",  "price":16, "icon_path":"res://Assets/StoreIcons/frutos/blackberry.png",       "label1":"Zarzamora",              "label2":"16 coins", "custom_button_text":"Comprar"},

	{"item_id":"blueberry_seeds",  "price":22, "icon_path":"res://Assets/StoreIcons/semillas/blueberry_seed.png", "label1":"Semilla de arándano",    "label2":"22 coins", "custom_button_text":"Comprar"},
	{"item_id":"blueberry_item",   "price":18, "icon_path":"res://Assets/StoreIcons/frutos/blueberry.png",        "label1":"Arándano",               "label2":"18 coins", "custom_button_text":"Comprar"},

	{"item_id":"raspberry_seeds",  "price":22, "icon_path":"res://Assets/StoreIcons/semillas/raspberry_seed.png", "label1":"Semilla de frambuesa",   "label2":"22 coins", "custom_button_text":"Comprar"},
	{"item_id":"raspberry_item",   "price":18, "icon_path":"res://Assets/StoreIcons/frutos/raspberry.png",        "label1":"Frambuesa",              "label2":"18 coins", "custom_button_text":"Comprar"}
]

func _ready() -> void:
	print("=== TIENDA INICIADA ===")
	setup_store()
	print("SCRIPT ACTIVO EN ESTE NODO: ", get_script().resource_path if get_script() else "SIN SCRIPT")

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
	print(">>> [TIENDA-Store] Señal recibida en Store.gd - ID: ", id)
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
