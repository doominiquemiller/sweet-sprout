extends StaticBody2D

# =============================================================
#  Counter — Mesa de Preparación con Tiempo Real (1 Minuto)
# =============================================================

@onready var area_2d = $Area2D
@onready var interaction_label : Label = $Label 

var player_present: bool = false
var recipe_menu_scene = preload("res://Scenes/Kitchen/crafting_menu.tscn")
var current_menu = null

# Variables del estado de preparación
var is_preparing: bool = false
var preparation_time_left: float = 0.0
var item_ready_to_collect: String = "" # Guarda el ID de la receta cruda terminada

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	
	if interaction_label:
		interaction_label.visible = false
		interaction_label.text = ""

func _process(delta: float) -> void:
	if is_preparing:
		preparation_time_left -= delta
		
		if preparation_time_left > 0:
			if interaction_label:
				interaction_label.text = "Preparando... %ds" % ceil(preparation_time_left)
				interaction_label.visible = true
		else:
			is_preparing = false
			preparation_time_left = 0.0
			_on_preparation_finished()

func _unhandled_key_input(event: InputEvent) -> void:
	if not player_present:
		return

	if event.is_pressed() and event.keycode == KEY_F:
		get_viewport().set_input_as_handled()
		
		if item_ready_to_collect != "":
			_collect_item()
			return
			
		if is_preparing:
			print("[Counter] El mueble está ocupado preparando una receta.")
			return
			
		toggle_recipe_menu()

func toggle_recipe_menu() -> void:
	if current_menu == null:
		print("[Counter] Abriendo menú de recetas...")
		current_menu = recipe_menu_scene.instantiate()
		
		var layer = CanvasLayer.new()
		layer.layer = 100
		layer.add_child(current_menu)
		get_tree().root.add_child(layer)
		
		if interaction_label:
			interaction_label.visible = false
		
		var player = get_tree().get_first_node_in_group("player") or get_tree().get_first_node_in_group("Player")
		if player:
			current_menu.open_menu(player, self)
	else:
		close_menu()

func close_menu() -> void:
	if current_menu != null:
		var layer = current_menu.get_parent()
		current_menu.queue_free()
		if layer is CanvasLayer:
			layer.queue_free()
		current_menu = null
		_update_label_state()

func start_preparation(result_item_id: String) -> void:
	close_menu()
	
	item_ready_to_collect = result_item_id
	preparation_time_left = 60.0
	is_preparing = true
	
	print("[Counter] Comenzando preparación de 60 segundos para: ", result_item_id)

func _on_preparation_finished() -> void:
	print("[Counter] ¡Preparación completada en tiempo real!")
	_update_label_state()

func _collect_item() -> void:
	print("[Counter] Entregando producto al jugador: ", item_ready_to_collect)
	Inventory.add_item(item_ready_to_collect, 1)
	
	item_ready_to_collect = ""
	_update_label_state()

func _update_label_state() -> void:
	if not interaction_label:
		return
		
	if not player_present and not is_preparing:
		interaction_label.visible = false
		return
		
	if is_preparing:
		interaction_label.visible = true
	elif item_ready_to_collect != "":
		interaction_label.text = "[F] Recoger mezcla lista"
		interaction_label.visible = true
	else:
		if player_present:
			interaction_label.text = "[F] Preparar Recetas"
			interaction_label.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player") or body.name == "Player":
		player_present = true
		_update_label_state()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player") or body.name == "Player":
		player_present = false
		_update_label_state()
		if current_menu != null:
			close_menu()
