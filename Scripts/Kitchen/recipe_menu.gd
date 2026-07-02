extends Control

# =============================================================
#  RecipeMenu — Mesa de Preparación (Agrupa ingredientes crudos)
# =============================================================

@onready var recipe_list_container = $Panel
@onready var grid : GridContainer = $ScrollContainer/GridContainer

@export var recipe_item : PackedScene
signal inventory_changed
var recipe_item_id : int = 0

var recipe_data : Array = [
	{
		"icon_path":"res://Assets/Recipes/raw_bread.png",
		"label1":"Masa de Pan Base",
		"label2":"Harina + Leche + Levadura",
		"button_text":"Preparar",
		"recipe_key":"Masa de Pan Base"
	},
	{
		"icon_path":"res://Assets/Recipes/raw_berry_cookies.png",
		"label1":"Masa de Galletas",
		"label2":"Harina + Mantequilla + Azúcar + Huevo",
		"button_text":"Preparar",
		"recipe_key":"Masa de Galletas de Bayas"
	},
	{
		"icon_path":"res://Assets/Recipes/raw_donuts.png",
		"label1":"Mezcla de Donas",
		"label2":"Harina + Leche + Huevo...",
		"button_text":"Preparar",
		"recipe_key":"Mezcla de Donas"
	},
]

var player_ref = null
var counter_ref = null

# Diccionario mapeado con los resultados en formato crudo/preparado para el horno
const RECIPES = {
	"Masa de Pan Base": {
		"ingredients": ["harina", "milk", "levadura"],
		"result": "raw_bread"
	},
	"Masa de Galletas de Bayas": {
		"ingredients": ["harina", "mantequilla", "azucar", "egg"],
		"optional_bayas": ["blueberry_item", "blackberry_item", "raspberry_item"],
		"result": "raw_berry_cookies"
	},
	"Mezcla de Donas": {
		"ingredients": ["harina", "milk", "egg", "levadura", "azucar", "aceite"],
		"optional_glaseado": ["honey"],
		"result": "raw_donuts"
	},
	"Mezcla de Pancakes Frutales": {
		"ingredients": ["harina", "milk", "egg", "mantequilla", "honey"],
		"optional_fruta": ["apple", "pear", "orange", "peach"],
		"result": "raw_pancakes"
	}
}



func open_menu(player, counter):
	player_ref = player
	counter_ref = counter
	setup_recipe_menu()

func setup_recipe_menu():
	print("grid =", grid)
	
	for child in grid.get_children():
		child.queue_free()
	recipe_item_id = 0
	for data in recipe_data:

		var temp = recipe_item.instantiate()

		temp.item_craft_pressed.connect(on_item_craft_pressed)

		grid.add_child(temp)

		var can_craft = check_ingredients(data["recipe_key"])

		temp.setup(data, recipe_item_id, can_craft)

		recipe_item_id += 1

func on_item_craft_pressed(id:int):

	var recipe_name = recipe_data[id]["recipe_key"]

	craft_recipe(recipe_name)

	setup_recipe_menu()

func check_ingredients(recipe_name: String) -> bool:
	var recipe = RECIPES[recipe_name]
	
	# 1. Comprobar ingredientes obligatorios mediante el Singleton Global de tu inventario
	for ing in recipe["ingredients"]:
		if not Inventory.has_item(ing, 1):
			return false
			
	# 2. Comprobar categorías opcionales (debe tener mínimo una unidad de cualquiera listada)
	if recipe.has("optional_bayas"):
		if not has_any_in_inventory(recipe["optional_bayas"]): return false
	if recipe.has("optional_glaseado"):
		if not has_any_in_inventory(recipe["optional_glaseado"]): return false
	if recipe.has("optional_fruta"):
		if not has_any_in_inventory(recipe["optional_fruta"]): return false
		
	return true

func has_any_in_inventory(options: Array) -> bool:
	for opt in options:
		if Inventory.has_item(opt, 1):
			return true
	return false

func craft_recipe(recipe_name: String):
	var recipe = RECIPES[recipe_name]
	print("[Counter] Preparando mezcla: ", recipe_name)
	
	# 1. Quitar ingredientes fijos obligatorios
	for ing in recipe["ingredients"]:
		Inventory.remove_item(ing, 1)
		
	# 2. Quitar el primer ingrediente opcional que encontremos que posea el jugador
	_consume_first_matching_optional(recipe, "optional_bayas")
	_consume_first_matching_optional(recipe, "optional_glaseado")
	_consume_first_matching_optional(recipe, "optional_fruta")
	
	# 3. Otorgar la preparación cruda lista para hornear
	Inventory.add_item(recipe["result"], 1)
	emit_signal("inventory_changed")
	print("[Counter] ¡Preparación terminada! %s listo para el horno." % recipe["result"])
	
	# Cerramos el menú notificando al counter
	if counter_ref:
		counter_ref.close_menu()
	else:
		queue_free()

func _consume_first_matching_optional(recipe: Dictionary, optional_key: String) -> void:
	if recipe.has(optional_key):
		for opt in recipe[optional_key]:
			if Inventory.has_item(opt, 1):
				Inventory.remove_item(opt, 1)
				break
