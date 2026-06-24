extends Node2D

# =============================================================
#  FruitTree — Controlador de Animaciones y Crecimiento
# =============================================================

# Referencias a los nodos hijos (Asegúrate de que se llamen así en tu escena FruitTree)
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var harvest_area    : Area2D           = $HarvestArea

# Estados de crecimiento del árbol (Corresponden a tus frames 0, 1 y 2)
enum TreeState { SPROUT = 0, ADULT = 1, READY_TO_HARVEST = 2 }

var current_state : TreeState = TreeState.SPROUT
var fruit_type    : String    = ""

# =============================================================
func _ready() -> void:
	# Nos añadimos al grupo global para que el botón de dormir nos encuentre al pasar la noche
	add_to_group("planted_trees")
	
	# Enlazamos la señal de colisión de forma segura desde el hijo Area2D
	if harvest_area:
		harvest_area.body_entered.connect(_on_player_entered_range)
		harvest_area.body_exited.connect(_on_player_exited_range)
	else:
		print("⚠️ [FruitTree] ERROR: No se encontró el nodo hijo 'HarvestArea' en la jerarquía.")

# =============================================================
#  CONFIGURACIÓN AL SEMBRAR
# =============================================================
func setup_tree(type: String) -> void:
	fruit_type = type
	current_state = TreeState.SPROUT  # Inicia como brote (Frame 0)
	print("[FruitTree] Sembrado árbol de: ", fruit_type)
	_update_tree_visuals()

func plant(type: String) -> void:
	setup_tree(type)

# =============================================================
#  CONTROL DE FRAMES VISUALES
# =============================================================
func _update_tree_visuals() -> void:
	if not animated_sprite:
		return

	# Si creaste una animación por fruta (ej: "apple"), reproduce esa animación y fija el frame del estado
	if animated_sprite.sprite_frames.has_animation(fruit_type):
		animated_sprite.play(fruit_type)
		animated_sprite.frame = current_state
	else:
		# Si usas la animación "default" para todo, descomenta las líneas de abajo:
		# animated_sprite.play("default")
		# animated_sprite.frame = current_state
		pass

# Función vital llamada por el sistema de dormir para avanzar las etapas
func advance_growth_state() -> void:
	if current_state < TreeState.READY_TO_HARVEST:
		current_state += 1 as TreeState
		_update_tree_visuals()
		print("[FruitTree] ¡El tiempo avanzó! Nuevo estado del árbol: ", current_state)

# =============================================================
#  DETECCIÓN INTERACTIVA
# =============================================================
func _on_player_entered_range(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		if current_state == TreeState.READY_TO_HARVEST:
			print("[FruitTree] ¡Cosecha lista! Presiona interactuar para recoger tu: ", fruit_type)
		else:
			print("[FruitTree] El árbol está creciendo. Estado actual: ", current_state)

func _on_player_exited_range(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		print("[FruitTree] El jugador se alejó del árbol.")
