extends Control

@onready var grid : GridContainer = $ScrollContainer/GridContainer

@export var store_item : PackedScene

var store_item_id : int = 0

var store_data: Array = [
	{
		"icon_path" : "res://Assets/StoreIcons/apple_seed.png",
		"label1" : "10 coins",
		"label2" : "value pack",
		"custom_button_text" : "10 Dia"
	}
]

func _ready() -> void:
	setup_store()
	
func setup_store() -> void:
	for data in store_data:
		var temp = store_item.instantiate()
		temp.item_buy_pressed.connect(on_item_buy_pressed)
		grid.add_child(temp)
		temp.setup(data, store_item_id)
		store_item_id += 1
		
func on_item_buy_pressed(id:int) -> void:
	print(store_data[id].get("label1")+" comprado.")
