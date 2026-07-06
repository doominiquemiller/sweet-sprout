extends CharacterBody2D

# Velocidad de caminata del personaje en píxeles por segundo
@export var velocidad: float = 120.0

# 🗺️ Capas del mapa asignables desde el inspector
@export var capa_cultivos: TileMapLayer 
@export var capa_suelo: TileMapLayer # <- ASIGNA AQUÍ TU CAPA DE SUELO PRINCIPAL O CONSTRUCCIONES

# Ajusta el tiempo entre pasos (en segundos)
const TIEMPO_ENTRE_PASOS := 0.35
var temporizador_pasos := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Referencia al sprite del ítem en la mano
@onready var item_en_mano_sprite: Sprite2D = $ItemEnMano

# Referencias a los reproductores de audio
@onready var pasos_cesped: AudioStreamPlayer2D = $PasosCesped
@onready var pasos_madera: AudioStreamPlayer2D = $PasosMadera

# Pre-cargamos la escena del árbol frutal para clonarla en el mapa
const FRUIT_TREE_SCENE = preload("res://Scenes/Items/Trees/fruit_trees.tscn") 

# Almacenamiento de celdas ocupadas localmente por seguridad
var celdas_ocupadas: Dictionary = {}

# 🎒 INVENTARIO DE INGREDIENTES LOCAL (Sincronizado en minúsculas con el sistema global)
var inventory: Array = ["harina", "milk", "levadura", "egg"]

# =============================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# SOLUCIÓN: Forzamos que el Player pertenezca a ambos grupos para que todo el mapa lo detecte
	if not is_in_group("player"):
		add_to_group("player")
	if not is_in_group("Player"):
		add_to_group("Player")
		
	# Nos aseguramos de que empiece oculto al arrancar
	if item_en_mano_sprite:
		item_en_mano_sprite.visible = false

func _physics_process(delta: float) -> void:
	# ACTUALIZAR EL ÍTEM VISUAL EN LA MANO
	_actualizar_item_en_mano()

	# 📦 CONGELAMIENTO EN INVENTARIO:
	if (Inventory and Inventory.visible):
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
	
	# Control de audio de pasos en base al movimiento real
	_procesar_sonido_pasos(delta)

# =============================================================
#  SISTEMA DE AUDIO PARA PASOS EN TILEMAP
# =============================================================
func _procesar_sonido_pasos(delta: float) -> void:
	if velocity.length() > 1.0:
		temporizador_pasos -= delta
		
		if temporizador_pasos <= 0:
			_reproducir_paso_segun_suelo()
			temporizador_pasos = TIEMPO_ENTRE_PASOS
	else:
		temporizador_pasos = 0.0

func _reproducir_paso_segun_suelo() -> void:
	var capa_a_leer : TileMapLayer = capa_suelo if capa_suelo else capa_cultivos
	
	if not capa_a_leer:
		pasos_cesped.play()
		return
		
	var posicion_celda : Vector2i = capa_a_leer.local_to_map(capa_a_leer.to_local(global_position))
	var source_id : int = capa_a_leer.get_cell_source_id(posicion_celda)
	
	# Si no hay nada en la capa principal, cambiamos COMPLETAMENTE a la capa de cultivos
	if source_id == -1 and capa_suelo and capa_cultivos:
		capa_a_leer = capa_cultivos
		posicion_celda = capa_a_leer.local_to_map(capa_a_leer.to_local(global_position))
		source_id = capa_a_leer.get_cell_source_id(posicion_celda)
	
	# Si ambas están vacías, asume césped por defecto
	if source_id == -1:
		pasos_cesped.play()
		return
		
	# Ahora sí extraemos las coordenadas usando la capa que de verdad contiene el bloque
	var coords_atlas : Vector2i = capa_a_leer.get_cell_atlas_coords(posicion_celda)
	
	print("ID Origen: ", source_id, " | Coordenadas Atlas: ", coords_atlas)
	
	# Condición limpia usando los datos exactos de image_019cf8.png
	if source_id == 0 and coords_atlas == Vector2i(1, 1):
		pasos_madera.play()
	else:
		pasos_cesped.play()

# =============================================================
#  MUESTRA U OCULTA EL ÍTEM EN LA MANO DEL PLAYER
# =============================================================
func _actualizar_item_en_mano() -> void:
	if not item_en_mano_sprite:
		return
		
	var item_id : String = Inventory.get_item_seleccionado()
	
	if item_id == "":
		item_en_mano_sprite.visible = false
		return
		
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
		var item_en_mano = Inventory.get_item_seleccionado()
		var semillas_validas: Array[String] = ["apple_seed", "orange_seed", "peach_seed", "pear_seed"]
		
		if item_en_mano in semillas_validas:
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

	var posicion_celda : Vector2i = capa_cultivos.local_to_map(capa_cultivos.to_local(global_position))
	
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
