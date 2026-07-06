extends Control

signal item_buy_pressed(id: int)

var item_data: Dictionary
var item_id: int = -1

@onready var icon: TextureRect = $HBoxContainer/MarginContainer/TextureRect
@onready var label1: Label = $HBoxContainer/MarginContainer2/VBoxContainer/Label
@onready var label2: Label = $HBoxContainer/MarginContainer2/VBoxContainer/Label2
@onready var buy_button: Button = $HBoxContainer/MarginContainer2/VBoxContainer/Button

func setup(data: Dictionary, id: int) -> void:
	print("StoreItem.setup() - Asignando ID: ", id, " para ", data.get("item_id", "unknown"))
	item_data = data
	item_id = id
	
	if icon and data.has("icon_path"):
		var texture = load(data["icon_path"])
		if texture:
			icon.texture = texture
	
	if label1 and data.has("label1"):
		label1.text = data["label1"]
	
	if label2 and data.has("label2"):
		label2.text = data["label2"]
	
	if buy_button and data.has("custom_button_text"):
		buy_button.text = data["custom_button_text"]
		
	# Desconectar para evitar duplicados
	if buy_button:
		if buy_button.pressed.is_connected(_on_buy_pressed):
			buy_button.pressed.disconnect(_on_buy_pressed)
		buy_button.pressed.connect(_on_buy_pressed)

func _ready() -> void:
	print("SCRIPT ACTIVO EN ESTE NODO: ", get_script().resource_path if get_script() else "SIN SCRIPT")

func _on_buy_pressed() -> void:
	print(">>> [TIENDA-StoreItem] Botón presionado - ID: ", item_id, " | Data: ", item_data.get("item_id", "no_data") if item_data else "null")
	item_buy_pressed.emit(item_id)
