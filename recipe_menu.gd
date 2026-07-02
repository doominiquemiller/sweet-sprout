extends Control

@onready var grid : GridContainer = $ScrollContainer/GridContainer

@export var recipe_item : PackedScene

var store_item_id : int = 0

var store_data: Array = [
	{
		"icon_path" : "res://Assets/StoreIcons/Egg_item.png",
		"label1" : "Huevo",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/Milk_item.png",
		"label1" : "Leche",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/flour.png",
		"label1" : "Harina",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/butter.png",
		"label1" : "Mantequilla",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/honey.png",
		"label1" : "Miel",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/oil.png",
		"label1" : "Aceite",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/yeast.png",
		"label1" : "Levadura",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/sugarcane.png",
		"label1" : "Caña de azúcar",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/semillas/wheat_seed.png",
		"label1" : "Semilla de trigo",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/frutos/wheat.png",
		"label1" : "Trigo",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/semillas/apple_seed.png",
		"label1" : "Semilla de manzana",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/frutos/apple.png",
		"label1" : "Manzana",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/semillas/orange_seed.png",
		"label1" : "Semilla de naranja",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/frutos/orange.png",
		"label1" : "Naranja",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/semillas/peach_seed.png",
		"label1" : "Semilla de melocotón",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/frutos/peach.png",
		"label1" : "Melocotón",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/semillas/pear_seed.png",
		"label1" : "Semilla de pera",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/frutos/pear.png",
		"label1" : "Pera",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/semillas/blackberry_seed.png",
		"label1" : "Semilla de zarzamora",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/frutos/blackberry.png",
		"label1" : "Zarzamora",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/semillas/blueberry_seed.png",
		"label1" : "Semilla de Arándano",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/frutos/blueberry.png",
		"label1" : "Arándano",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/semillas/raspberry_seed.png",
		"label1" : "Semilla de Frambuesa",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	},
	{
		"icon_path" : "res://Assets/StoreIcons/frutos/raspberry.png",
		"label1" : "Frambuesa",
		"label2" : "10 coins",
		"custom_button_text" : "Buy"
	}
]

func _ready() -> void:
	
	setup_store()
	print(size)
	print(global_position)
	print("Parent:", get_parent())
	print("Visible:", visible)
	print("Position:", position)
	print("Global:", global_position)
	print("Grid:", grid)
	modulate = Color.RED
	
func setup_store() -> void:
	for data in store_data:
		var temp = recipe_item.instantiate()
		temp.item_buy_pressed.connect(on_item_buy_pressed)
		grid.add_child(temp)
		temp.setup(data, store_item_id)
		store_item_id += 1
		
func on_item_buy_pressed(id:int) -> void:
	print(store_data[id].get("label1")+" comprado.")


func _on_texture_button_pressed() -> void:
	queue_free()
