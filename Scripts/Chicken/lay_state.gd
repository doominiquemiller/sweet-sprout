extends State

@export var character  : CharacterBody2D
@export var animation  : AnimatedSprite2D
@export var egg_spawn  : Marker2D

const EGG_SCENE := preload("res://Scenes/Items/egg.tscn")

const LAY_ANIMATION_NAME : String = "idle"
const LAY_DURATION_FALLBACK : float = 1.0

var _finished : bool = false
var _timer    : float = 0.0

# =============================================================
func _on_enter() -> void:
	_finished = false
	_timer = 0.0

	if animation.sprite_frames.has_animation(LAY_ANIMATION_NAME):
		animation.play(LAY_ANIMATION_NAME)
		if not animation.sprite_frames.get_animation_loop(LAY_ANIMATION_NAME):
			animation.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
	else:
		push_warning("Lay: animación '%s' no encontrada" % LAY_ANIMATION_NAME)

func _on_exit() -> void:
	animation.stop()
	_finished = false
	if animation.animation_finished.is_connected(_on_animation_finished):
		animation.animation_finished.disconnect(_on_animation_finished)

func _on_process(_delta: float) -> void:
	pass

func _on_physics_process(delta: float) -> void:
	character.velocity = Vector2.ZERO
	character.move_and_slide()

	if animation.sprite_frames.get_animation_loop(LAY_ANIMATION_NAME):
		_timer += delta
		if _timer >= LAY_DURATION_FALLBACK and not _finished:
			_spawn_egg()
			_finished = true

func _on_next_transitions() -> void:
	if _finished:
		transition.emit("idle")

# =============================================================
func _on_animation_finished() -> void:
	_spawn_egg()
	_finished = true

func _spawn_egg() -> void:
	if not egg_spawn:
		push_error("[Lay] egg_spawn es NULL — asigna el Marker2D en el Inspector")
		# Fallback: usar la posición de la gallina si no hay spawn point
		_instantiate_egg(character.global_position)
		return

	_instantiate_egg(egg_spawn.global_position)

func _instantiate_egg(pos: Vector2) -> void:
	var egg = EGG_SCENE.instantiate()

	# Lo añadimos al MISMO padre que la gallina, para que esté
	# en la misma capa de Y-Sort y se vea en el mundo, no detrás de UI
	var world_parent : Node = character.get_parent()
	world_parent.add_child(egg)

	egg.global_position = pos
	egg.z_index = 5  # asegura que esté por encima del suelo/tiles

	print("[Lay] Huevo creado en: ", egg.global_position, " padre: ", world_parent.name)
