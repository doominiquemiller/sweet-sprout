extends Control

# =============================================================
#  RecipeMenu — Envia la orden de preparado al Counter
# =============================================================

@onready var recipe_list_container = $Panel

var player_ref = null
var counter_ref = null

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
		
		var can_craft = check_ingredients(recipe_name)
		
		btn.disabled = not can_craft
		btn.pressed.connect(func(): craft_recipe(recipe_name))
		recipe_list_container.add_child(btn)

func check_ingredients(recipe_name: String) -> bool:
	var recipe = RECIPES[recipe_name]
	for ing in recipe["ingredients"]:
		if not Inventory.has_item(ing, 1):
			return false
			
	if recipe.has("optional_bayas") and not has_any_in_inventory(recipe["optional_bayas"]): return false
	if recipe.has("optional_glaseado") and not has_any_in_inventory(recipe["optional_glaseado"]): return false
	if recipe.has("optional_fruta") and not has_any_in_inventory(recipe["optional_fruta"]): return false
		
	return true

func has_any_in_inventory(options: Array) -> bool:
	for opt in options:
		if Inventory.has_item(opt, 1):
			return true
	return false

func craft_recipe(recipe_name: String):
	var recipe = RECIPES[recipe_name]
	print("[RecipeMenu] Enviando ingredientes al counter para preparar: ", recipe_name)
	
	# Consumimos los materiales del inventario de inmediato
	for ing in recipe["ingredients"]:
		Inventory.remove_item(ing, 1)
		
	_consume_first_matching_optional(recipe, "optional_bayas")
	_consume_first_matching_optional(recipe, "optional_glaseado")
	_consume_first_matching_optional(recipe, "optional_fruta")
	
	# Le decimos al counter que empiece a trabajar durante 1 minuto
	if counter_ref and counter_ref.has_method("start_preparation"):
		counter_ref.start_preparation(recipe["result"])
	else:
		queue_free()

func _consume_first_matching_optional(recipe: Dictionary, optional_key: String) -> void:
	if recipe.has(optional_key):
		for opt in recipe[optional_key]:
			if Inventory.has_item(opt, 1):
				Inventory.remove_item(opt, 1)
				break
