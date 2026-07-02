extends StaticBody2D

# =============================================================
#  Counter — Objeto de Interacción para Cocina (Con Label)
# =============================================================

@onready var area_2d = $Area2D
# Asegúrate de añadir un nodo Label como hijo de tu escena Counter y arrastrarlo aquí o llamarlo $Label
@onready var interaction_label : Label = $Label

var player_present: bool = false
@export var recipe_scene: PackedScene
var current_menu = null

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	
	# El texto empieza oculto o vacío hasta que el jugador se acerque
	if interaction_label:
		interaction_label.visible = false
		interaction_label.text = ""

func _unhandled_key_input(event: InputEvent) -> void:
	if not player_present:
		return

	# Detección de la tecla F
	if event.is_pressed() and event.keycode == KEY_F:
		get_viewport().set_input_as_handled()
		toggle_recipe_menu()


func toggle_recipe_menu() -> void:
	if current_menu == null:
		current_menu = recipe_scene.instantiate()
		current_menu.position = Vector2(276, 124)
		get_tree().current_scene.add_child(current_menu)
		
		print(current_menu.get_parent().name)
		print(current_menu.get_index())

		print(current_menu.position)

		current_menu.position = Vector2(276, 124)

		print(current_menu.position)
		
		await get_tree().create_timer(2.0).timeout
		print(is_instance_valid(current_menu))
		current_menu.z_index = 99
		print(get_tree().current_scene)
		print(get_tree().root)
		
		if interaction_label:
			interaction_label.visible = false
	else:
		close_menu()

func close_menu() -> void:
	if current_menu:
		current_menu.queue_free()
		current_menu = null

		if player_present:
			interaction_label.visible = true
			interaction_label.text = "[F] Preparar Recetas"

# =============================================================
#  DETECCIÓN Y FEEDBACK VISUAL
# =============================================================
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player") or body.name == "Player":
		player_present = true
		
		# Mostramos el mensaje en el Label al acercarse
		if interaction_label:
			interaction_label.text = "[F] Preparar Recetas"
			interaction_label.visible = true
		print("[Counter] Jugador detectado en cocina.")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player") or body.name == "Player":
		player_present = false
		
		# Ocultamos y limpiamos el Label al alejarse
		if interaction_label:
			interaction_label.visible = false
			interaction_label.text = ""
		close_menu()
