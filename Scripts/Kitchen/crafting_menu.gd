extends Control

@onready var grid : GridContainer = $ScrollContainer/GridContainer

@export var store_item : PackedScene

var store_item_id : int = 0

# Referencias que llegan desde el Counter al abrir el menú
var player_ref = null
var counter_ref = null

# Base de datos de recetas: ingredientes, resultado crudo e icono
var recipe_data: Array = [
	{
		"item_id": "raw_bread",
		"label1": "Masa de Pan Base",
		"ingredients": ["flour", "milk", "yeast"],
		"icon_path": "res://Assets/raw_recipes/raw_bread.png",
		"custom_button_text": "Preparar"
	},
	{
		"item_id": "raw_berry_cookies",
		"label1": "Masa de Galletas de Bayas",
		"ingredients": ["flour", "butter", "sugar_cane", "egg"],
		"icon_path": "res://Assets/raw_recipes/raw_berry_cookies.png",
		"custom_button_text": "Preparar"
	},
	{
		"item_id": "raw_donuts",
		"label1": "Mezcla de Donas",
		"ingredients": ["flour", "milk", "egg", "yeast", "oil"],
		"icon_path": "res://Assets/raw_recipes/raw_donuts.png",
		"custom_button_text": "Preparar"
	},
	{
		"item_id": "raw_pancakes",
		"label1": "Mezcla de Pancakes Frutales",
		"ingredients": ["flour", "milk", "egg", "butter", "honey"],
		"icon_path": "res://Assets/raw_recipes/raw_pancakes.png",
		"custom_button_text": "Preparar"
	}
]

func _ready() -> void:
	setup_recipe_menu()

# =============================================================
#  Llamado desde counter_4.gd (toggle_recipe_menu) al abrir el menú
# =============================================================
func open_menu(p_player, p_counter) -> void:
	player_ref = p_player
	counter_ref = p_counter
	visible = true
	setup_recipe_menu()

func setup_recipe_menu() -> void:
	store_item_id = 0

	for child in grid.get_children():
		child.queue_free()

	for data in recipe_data:
		var temp = store_item.instantiate()
		grid.add_child(temp)

		temp.item_buy_pressed.connect(on_prepare_pressed)

		var ingredients_text = "Ingredientes: " + ", ".join(data["ingredients"])

		var display_data = data.duplicate()
		display_data["label2"] = ingredients_text

		temp.setup(display_data, store_item_id)

		var can_craft = check_ingredients(data["ingredients"])
		var button_path = "HBoxContainer/MarginContainer2/VBoxContainer/Button"
		if temp.has_node(button_path):
			temp.get_node(button_path).disabled = not can_craft

		store_item_id += 1

func check_ingredients(ingredients: Array) -> bool:
	for ing in ingredients:
		# CORREGIDO: Ahora consulta stock usando el Autoload Global
		if not Global.has_item(ing, 1):
			return false
	return true

# =============================================================
#  Consume ingredientes y avisa al Counter para iniciar el
#  temporizador real de 60 segundos (en vez de dar el item al instante)
# =============================================================
func on_prepare_pressed(id: int) -> void:
	if id < 0 or id >= recipe_data.size():
		return

	var recipe = recipe_data[id]
	var required_ingredients = recipe["ingredients"]
	var raw_item_result = recipe["item_id"]

	print("\n=== [MESA DE TRABAJO] Intentando preparar: ", recipe["label1"], " ===")

	if check_ingredients(required_ingredients):
		for ing in required_ingredients:
			# CORREGIDO: Consume los ingredientes usando Global
			Global.remove_item(ing, 1)

		print("[ÉXITO] Ingredientes consumidos, iniciando preparación de: ", raw_item_result)

		if counter_ref and counter_ref.has_method("start_preparation"):
			counter_ref.start_preparation(raw_item_result)
		else:
			push_warning("[CraftingMenu] No hay counter_ref válido, entregando item directo.")
			# CORREGIDO: Entrega de ítem de emergencia usando Global
			Global.add_item(raw_item_result, 1)
			queue_free()
	else:
		print("[ERROR] No tienes los ingredientes suficientes.")
	print("============================================\n")

func _on_texture_button_pressed() -> void:
	queue_free()
