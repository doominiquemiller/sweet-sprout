extends CharacterBody2D

# Velocidad de caminata del personaje en píxeles por segundo
@export var velocidad: float = 120.0

# Capa del mapa o sistema de plantación asignable desde el inspector
@export var capa_cultivos: TileMapLayer 

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# 🖐️ NUEVO: Referencia al sprite del ítem en la mano
@onready var item_en_mano_sprite: Sprite2D = $ItemEnMano

# Pre-cargamos la escena del árbol frutal para clonarla en el mapa
const FRUIT_TREE_SCENE = preload("res://Scenes/Items/Trees/fruit_trees.tscn") 

# Almacenamiento de celdas ocupadas localmente por seguridad
var celdas_ocupadas: Dictionary = {}

# =============================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Nos aseguramos de que empiece oculto al arrancar
	if item_en_mano_sprite:
		item_en_mano_sprite.visible = false

func _physics_process(_delta: float) -> void:
	# ACTUALIZAR EL ÍTEM VISUAL EN LA MANO
	_actualizar_item_en_mano()

	# 📦 CONGELAMIENTO EN INVENTARIO:
	# Si el inventario está abierto, el jugador se detiene pero mantiene la escucha de acciones
	if Inventory and Inventory.visible:
		velocity = Vector2.ZERO
		actualizar_animacion_8_vias(Vector2.ZERO)
		return

	# Obtener dirección del movimiento normal
	var direccion : Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if direccion != Vector2.ZERO:
		velocity = direccion.normalized() * velocidad
	else:
		velocity = velocity.move_toward(Vector2.ZERO, velocidad)
	
	move_and_slide()
	actualizar_animacion_8_vias(direccion)

# =============================================================
#  MUESTRA U OCULTA EL ÍTEM EN LA MANO DEL PLAYER
# =============================================================
func _actualizar_item_en_mano() -> void:
	if not item_en_mano_sprite:
		return
		
	var item_id : String = Inventory.get_item_seleccionado()
	
	# Si no hay nada seleccionado, ocultamos el sprite de la mano
	if item_id == "":
		item_en_mano_sprite.visible = false
		return
		
	# Buscamos si el inventario global tiene la textura de ese ítem registrada
	if Inventory.ITEM_ICONS.has(item_id):
		item_en_mano_sprite.texture = Inventory.ITEM_ICONS[item_id]
		item_en_mano_sprite.visible = true
	else:
		item_en_mano_sprite.visible = false

# =============================================================
#  SISTEMA DE INTERACCIÓN 
# =============================================================
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_F):
		_intentar_plantar()

func _intentar_plantar() -> void:
	if not capa_cultivos:
		return

	var inventario_global = Inventory 
	if not inventario_global:
		return
		
	var item_en_mano : String = inventario_global.get_item_seleccionado()
	if item_en_mano == "":
		print("No hay semilla seleccionada.")
		return
		
	var semillas_validas : Array[String] = ["apple_seed", "orange_seed", "peach_seed", "pear_seed"]
	if not item_en_mano in semillas_validas:
		return

	# Obtener coordenadas de la celda actual del jugador
	var posicion_celda : Vector2i = capa_cultivos.local_to_map(capa_cultivos.to_local(global_position))
	
	# Verificar si el terreno es válido
	if capa_cultivos.get_cell_source_id(posicion_celda) == -1:
		print("Aquí no se puede plantar.")
		return
		
	if celdas_ocupadas.has(posicion_celda):
		print("Espacio de cultivo ocupado.")
		return

	if not inventario_global.has_item(item_en_mano, 1):
		inventario_global.limpiar_seleccion()
		return

	var tipo_fruta : String = item_en_mano.replace("_seed", "")
	
	var se_quito : bool = inventario_global.remove_item(item_en_mano, 1)
	
	if se_quito:
		var nuevo_arbol = FRUIT_TREE_SCENE.instantiate()
		get_parent().add_child(nuevo_arbol)
		
		var posicion_centrada : Vector2 = capa_cultivos.map_to_local(posicion_celda)
		nuevo_arbol.global_position = capa_cultivos.to_global(posicion_centrada)
		
		celdas_ocupadas[posicion_celda] = nuevo_arbol
		
		if nuevo_arbol.has_method("setup_tree"):
			nuevo_arbol.setup_tree(tipo_fruta)
			
		print("¡Sembraste: ", tipo_fruta, "!")
		
		nuevo_arbol.tree_exiting.connect(func():
			celdas_ocupadas.erase(posicion_celda)
		)
		
		if not inventario_global.has_item(item_en_mano, 1):
			inventario_global.limpiar_seleccion()

# =============================================================
#  ANIMACIÓN DE MOVIMIENTO
# =============================================================
func actualizar_animacion_8_vias(direccion: Vector2) -> void:
	if direccion == Vector2.ZERO:
		if sprite.is_playing():
			sprite.stop()
		return
		
	if not sprite.is_playing():
		sprite.play()

	var angulo : float = rad_to_deg(direccion.angle())
	
	if angulo > -22.5 and angulo <= 22.5:
		sprite.animation = "right"
	elif angulo > 22.5 and angulo <= 67.5:
		sprite.animation = "down_right"
	elif angulo > 67.5 and angulo <= 112.5:
		sprite.animation = "down"
	elif angulo > 112.5 and angulo <= 157.5:
		sprite.animation = "down_left"
	elif angulo > 157.5 or angulo <= -157.5:
		sprite.animation = "left"
	elif angulo > -157.5 and angulo <= -112.5:
		sprite.animation = "up_left"
	elif angulo > -112.5 and angulo <= -67.5:
		sprite.animation = "up"
	elif angulo > -67.5 and angulo <= -22.5:
		sprite.animation = "up_right"
