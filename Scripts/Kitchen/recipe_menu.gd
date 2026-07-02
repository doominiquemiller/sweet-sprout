extends Control

# =============================================================
#  RecipeMenu — Mesa de Preparación (Agrupa ingredientes crudos)
# =============================================================

@onready var recipe_list_container = $Panel/VBoxContainer 

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
	update_recipe_list()

func update_recipe_list():
	for child in recipe_list_container.get_children():
		child.queue_free()
		
	for recipe_name in RECIPES.keys():
		var btn = Button.new()
		btn.text = recipe_name
		
		# Valida la disponibilidad usando tu script global de Inventario
		var can_craft = check_ingredients(recipe_name)
		
		btn.disabled = not can_craft
		btn.pressed.connect(func(): craft_recipe(recipe_name))
		recipe_list_container.add_child(btn)

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
