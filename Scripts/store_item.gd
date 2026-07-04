extends PanelContainer

signal item_buy_pressed(id: int)

var item_data: Dictionary
var item_id: int = -1

@onready var icon: TextureRect = $Icon
@onready var label1: Label = $Label1
@onready var label2: Label = $Label2
@onready var buy_button: Button = $BuyButton

func setup(data: Dictionary, id: int) -> void:
	item_data = data
	item_id = id
	
	# Configurar UI
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

func _on_buy_button_pressed() -> void:
	print("[StoreItem] Botón presionado - ID: ", item_id)
	item_buy_pressed.emit(item_id)
