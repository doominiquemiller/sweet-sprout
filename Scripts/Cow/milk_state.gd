extends State

# =============================================================
#  MilkState — Estado de dar leche (Corregido y Optimizado)
# =============================================================

@export var character    : CharacterBody2D
@export var animation    : AnimatedSprite2D
@export var milk_spawn   : Marker2D   # Arrastra tu MilkSpawnPoint aquí en el Inspector

const MILK_SCENE := preload("res://Scenes/Animals/milk.tscn")

# TEMPORAL: usa "idle" mientras no tengas animación de dar leche.
const MILK_ANIMATION_NAME : String = "idle"
const MILK_DURATION_FALLBACK : float = 1.0

var _finished : bool = false
var _timer    : float = 0.0

# =============================================================
func _on_enter() -> void:
	_finished = false
	_timer = 0.0

	if animation == null:
		print("⚠️ [MilkState] ERROR: No has arrastrado el AnimatedSprite2D al estado Milk en el Inspector.")
		_finished = true # Falla seguro para no congelar la máquina de estados
		return

	if animation.sprite_frames.has_animation(MILK_ANIMATION_NAME):
		animation.play(MILK_ANIMATION_NAME)
		
		# Si la animación NO es en bucle (no loop), se conecta al terminar
		if not animation.sprite_frames.get_animation_loop(MILK_ANIMATION_NAME):
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
	if animation and animation.sprite_frames.has_animation(MILK_ANIMATION_NAME):
		if animation.sprite_frames.get_animation_loop(MILK_ANIMATION_NAME):
			_timer += delta
			if _timer >= MILK_DURATION_FALLBACK:
				_finished = true # Se marca antes para evitar llamadas repetidas en el proceso
				_spawn_milk()

func _on_next_transitions() -> void:
	if _finished:
		transition.emit("idle")

# =============================================================
# Se dispara si la animación NO tiene activado el loop
func _on_animation_finished() -> void:
	if _finished:
		return
	_finished = true
	_spawn_milk()

func _spawn_milk() -> void:
	var pos : Vector2 = milk_spawn.global_position if milk_spawn else character.global_position
	_instantiate_milk(pos)

func _instantiate_milk(pos: Vector2) -> void:
	if not MILK_SCENE:
			print("⚠️ [MilkState] ERROR: La escena milk.tscn no está cargada.")
			return
		
	var milk = MILK_SCENE.instantiate()
	
	# SOLUCIÓN: Agrega la leche a la raíz de la escena activa (el mundo global)
	var main_tree_root = character.get_tree().current_scene
	
	if main_tree_root:
		main_tree_root.add_child(milk)
		milk.global_position = pos
		milk.z_index = 5
		print("[MilkState] ¡Leche generada en el suelo del mundo global de forma segura!")
