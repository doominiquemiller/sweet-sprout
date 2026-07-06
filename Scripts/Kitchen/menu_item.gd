extends PanelContainer

signal item_buy_pressed(item_id: int)

@onready var texture = $HBoxContainer/MarginContainer/TextureRect
@onready var label1 = $HBoxContainer/MarginContainer2/VBoxContainer/Label
@onready var label2 = $HBoxContainer/MarginContainer2/VBoxContainer/Label2
@onready var button = $HBoxContainer/MarginContainer2/VBoxContainer/Button

var id : int

func _ready() -> void:
	if not button.pressed.is_connected(_on_button_pressed):
		button.pressed.connect(_on_button_pressed)
	print("SCRIPT ACTIVO EN ESTE NODO: ", get_script().resource_path if get_script() else "SIN SCRIPT")

func setup(data: Dictionary, p_id: int) -> void:
	if ResourceLoader.exists(data.get("icon_path", "")):
		texture.texture = load(data.get("icon_path"))

	label1.text = data.get("label1", "")
	label2.text = data.get("label2", "")
	id = p_id

	if data.get("custom_button_text"):
		button.text = data.get("custom_button_text")

func _on_button_pressed() -> void:
	print("[MENUITEM-PanelContainer] Botón presionado físicamente, id: ", id)
	item_buy_pressed.emit(id)
