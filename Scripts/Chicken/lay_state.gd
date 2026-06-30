extends State

# =============================================================
#  LayState — Estado de poner huevo (Corregido y Optimizado)
# =============================================================

@export var character  : CharacterBody2D
@export var animation  : AnimatedSprite2D
@export var egg_spawn  : Marker2D # Arrastra tu EggSpawnPoint aquí en el Inspector

const EGG_SCENE := preload("res://Scenes/Animals/egg.tscn")

const LAY_ANIMATION_NAME : String = "idle"
const LAY_DURATION_FALLBACK : float = 1.0

var _finished : bool = false
var _timer    : float = 0.0

# =============================================================
func _on_enter() -> void:
	_finished = false
	_timer = 0.0

	if animation == null:
		print("⚠️ [LayState] ERROR: No has arrastrado el AnimatedSprite2D al estado Lay en el Inspector.")
		_finished = true
		return

	if animation.sprite_frames.has_animation(LAY_ANIMATION_NAME):
		animation.play(LAY_ANIMATION_NAME)
		
		# Si la animación NO es en bucle (no loop), se conecta al terminar
		if not animation.sprite_frames.get_animation_loop(LAY_ANIMATION_NAME):
			if not animation.animation_finished.is_connected(_on_animation_finished):
				animation.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func _on_exit() -> void:
	if animation:
		animation.stop()
		if animation.animation_finished.is_connected(_on_animation_finished):
			animation.animation_finished.disconnect(_on_animation_finished)
	_finished = false

func _on_process(_delta: float) -> void:
	pass

func _on_physics_process(delta: float) -> void:
	if _finished:
		return

	character.velocity = Vector2.ZERO
	character.move_and_slide()

	# Fallback por si la animación tiene ACTIVADO el Loop (Bucle)
	if animation and animation.sprite_frames.has_animation(LAY_ANIMATION_NAME):
		if animation.sprite_frames.get_animation_loop(LAY_ANIMATION_NAME):
			_timer += delta
			if _timer >= LAY_DURATION_FALLBACK:
				_finished = true # Bloqueamos llamadas extras inmediatamente
				_spawn_egg()

func _on_next_transitions() -> void:
	if _finished:
		transition.emit("idle")

# Se dispara si la animación NO tiene activado el loop
func _on_animation_finished() -> void:
	if _finished:
		return
	_finished = true
	_spawn_egg()

# =============================================================
func _spawn_egg() -> void:
	var pos : Vector2 = egg_spawn.global_position if egg_spawn else character.global_position
	_instantiate_egg(pos)

func _instantiate_egg(pos: Vector2) -> void:
	if not EGG_SCENE:
		print("⚠️ [LayState] ERROR: La escena egg.tscn no está cargada o la ruta es incorrecta.")
		return
		
	var egg = EGG_SCENE.instantiate()
	
	# SOLUCIÓN DE SEGURIDAD: Instanciar en la escena raíz del mapa de juego actual
	var main_tree_root = character.get_tree().current_scene
	
	if main_tree_root:
		main_tree_root.add_child(egg)
		egg.global_position = pos
		egg.z_index = 5
		print("[LayState] ¡Huevo generado en el suelo del mundo global con éxito!")
