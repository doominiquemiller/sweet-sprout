extends Control

@onready var grid : GridContainer = $ScrollContainer/GridContainer
@export var store_item : PackedScene

var store_item_id : int = 0

var store_data: Array = [
	{
		"item_id": "apple_seed",
		"price": 40,
		"icon_path": "res://Assets/Seeds/apple_seed.png",
		"label1": "Semilla de Manzana",
		"label2": "40 coins",
		"custom_button_text": "Buy"
	},
	{
		"item_id": "orange_seed",
		"price": 40,
		"icon_path": "res://Assets/Seeds/orange_seed.png",
		"label1": "Semilla de Naranja",
		"label2": "40 coins",
		"custom_button_text": "Buy"
	},
	{
		"item_id": "peach_seed",
		"price": 45,
		"icon_path": "res://Assets/Seeds/peach_seed.png",
		"label1": "Semilla de Melocotón",
		"label2": "45 coins",
		"custom_button_text": "Buy"
	},
	{
		"item_id": "pear_seed",
		"price": 40,
		"icon_path": "res://Assets/Seeds/pear_seed.png",
		"label1": "Semilla de Pera",
		"label2": "40 coins",
		"custom_button_text": "Buy"
	},
	{
		"item_id": "wheat_seed",
		"price": 6,
		"icon_path": "res://Assets/StoreIcons/semillas/wheat_seed.png",
		"label1": "Semilla de Trigo",
		"label2": "6 coins",
		"custom_button_text": "Buy"
	},
	{
		"item_id": "sugarcane_seed",
		"price": 20,
		"icon_path": "res://Assets/Seeds/sugarcane_seed.png",
		"label1": "Semilla de Caña de Azúcar",
		"label2": "20 coins",
		"custom_button_text": "Buy"
	},
	{
		"item_id": "milk",
		"price": 15,
		"icon_path": "res://Assets/Objects/Milk_item.png",
		"label1": "Leche",
		"label2": "15 coins",
		"custom_button_text": "Buy"
	},
	{
		"item_id": "egg",
		"price": 8,
		"icon_path": "res://Assets/Objects/Egg item.png",
		"label1": "Huevo",
		"label2": "8 coins",
		"custom_button_text": "Buy"
	},
	{
		"item_id": "honey",
		"price": 18,
		"icon_path": "res://Assets/Objects/Honey_item.png",
		"label1": "Miel",
		"label2": "18 coins",
		"custom_button_text": "Buy"
	}
]

func _ready() -> void:
	print("[Store] Inicializando tienda...")
	setup_store()
	print("[Store] Tienda inicializada. Dinero actual: ", Global.get_money())

func setup_store() -> void:
	store_item_id = 0

	# Limpiar grid
	for child in grid.get_children():
		child.queue_free()
	
	# Esperar un frame para que los hijos se eliminen
	await get_tree().process_frame

	# Crear items
	for data in store_data:
		var temp = store_item.instantiate()
		grid.add_child(temp)
		temp.item_buy_pressed.connect(on_item_buy_pressed)
		temp.setup(data, store_item_id)
		store_item_id += 1
		print("[Store] Item creado: ", data["item_id"], " con ID: ", store_item_id - 1)

func on_item_buy_pressed(id: int) -> void:
	print("=" * 50)
	print("[Store] 🔔 SEÑAL RECIBIDA - ID: ", id)
	print("=" * 50)

	if id < 0 or id >= store_data.size():
		print("[Store] ❌ ID fuera de rango: ", id, " | Tamaño: ", store_data.size())
		return

	var data = store_data[id]
	var item_id : String = data.get("item_id", "")
	var price : int = data.get("price", 0)
	
	print("[Store] 📦 Item: ", item_id)
	print("[Store] 💰 Precio: ", price)
	print("[Store] 💵 Dinero actual: ", Global.get_money())

	if item_id == "":
		push_warning("[Store] ❌ El item no tiene 'item_id' configurado.")
		return

	# Verificar si tiene suficiente dinero
	if Global.get_money() < price:
		print("[Store] ❌ FONDOS INSUFICIENTES. Tienes: ", Global.get_money(), " | Necesitas: ", price)
		# Mostrar mensaje al jugador (opcional)
		return

	# Intentar gastar dinero
	print("[Store] Intentando gastar ", price, " coins...")
	var success = Global.spend_money(price)
	
	if success:
		print("[Store] ✅ Dinero gastado exitosamente. Nuevo total: ", Global.get_money())
		
		# Buscar el inventario
		var inventory = get_tree().get_first_node_in_group("inventory")
		print("[Store] 🔍 Buscando inventario... Encontrado: ", inventory != null)
		
		if inventory:
			if inventory.has_method("add_item"):
				print("[Store] 📥 Añadiendo item: ", item_id)
				inventory.add_item(item_id, 1)
				print("[Store] ✅ Item añadido al inventario")
			else:
				print("[Store] ❌ El inventario no tiene método 'add_item'")
		else:
			print("[Store] ❌ No se encontró el sistema de inventario")
	else:
		print("[Store] ❌ Falló al gastar el dinero")

	print("=" * 50)

func _on_texture_button_pressed() -> void:
	queue_free()
