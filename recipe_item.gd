extends PanelContainer

signal item_buy_pressed(id)

@onready var texture = $HBoxContainer/MarginContainer/TextureRect
@onready var label1 = $HBoxContainer/MarginContainer2/VBoxContainer/Label
@onready var label2 = $HBoxContainer/MarginContainer2/VBoxContainer/Label2
@onready var button = $HBoxContainer/MarginContainer2/VBoxContainer/Button

var id : int

func setup(data: Dictionary, p_id: int) -> void:
	texture.texture = load(data.get("icon_path"))
	label1.text = data.get("label1", "")
	label2.text = data.get("label2", "")
	id = p_id
	
	if data.get("custom_button_text"):
		button.text = data.get("custom_button_text")
	

func _on_button_pressed() -> void:
	emit_signal("item_buy_pressed", id)
