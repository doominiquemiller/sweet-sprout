extends Node2D

# =============================================================
#  FruitTree — Controlador de Animaciones y Ciclo de Vida
# =============================================================

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var harvest_area    : Area2D           = $HarvestArea

enum TreeState { SPROUT = 0, ADULT = 1, READY_TO_HARVEST = 2 }

var current_state : TreeState = TreeState.SPROUT
var fruit_type    : String    = ""

func _enter_tree() -> void:
	# Forzamos al nodo a registrarse en el grupo global antes de su _ready
	if not is_in_group("planted_trees"):
		add_to_group("planted_trees")

func _ready() -> void:
	if harvest_area:
		harvest_area.monitoring = true
		harvest_area.monitorable = true
		if not harvest_area.body_entered.is_connected(_on_player_entered_range):
			harvest_area.body_entered.connect(_on_player_entered_range)
		if not harvest_area.body_exited.is_connected(_on_player_exited_range):
			harvest_area.body_exited.connect(_on_player_exited_range)
			
	_update_tree_visuals()

func setup_tree(type: String) -> void:
	fruit_type = type
	current_state = TreeState.SPROUT
	_update_tree_visuals()

func plant(type: String) -> void:
	setup_tree(type)

func _update_tree_visuals() -> void:
	if not animated_sprite:
		return

	# Si usas animaciones con el nombre de cada fruta (ej: "apple"), fijamos su frame (0, 1 o 2)
	if animated_sprite.sprite_frames.has_animation(fruit_type):
		animated_sprite.play(fruit_type)
		animated_sprite.frame = current_state
		animated_sprite.stop() # Evita que la animación avance sola por segundo
	else:
		# Por si usas una animación por defecto con todos los frames juntos
		if animated_sprite.sprite_frames.has_animation("default"):
			animated_sprite.play("default")
			animated_sprite.frame = current_state
			animated_sprite.stop()

# Función que manda a llamar el botón de Dormir para pasar de día
func advance_growth_state() -> void:
	if current_state < TreeState.READY_TO_HARVEST:
		current_state += 1 as TreeState
		_update_tree_visuals()
		print("[FruitTree] El tiempo avanzó. Nuevo estado de frame visual: ", current_state)

func _on_player_entered_range(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		print("[FruitTree] Jugador entró al rango del árbol de: ", fruit_type)
		if current_state == TreeState.READY_TO_HARVEST:
			print("[FruitTree] ¡Cosecha lista para recoger con F!")

func _on_player_exited_range(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		print("[FruitTree] El jugador se alejó del árbol.")
