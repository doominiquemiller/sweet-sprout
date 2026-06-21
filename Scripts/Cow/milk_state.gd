extends State

# =============================================================
#  MilkState — Estado de dar leche
#  Igual patrón que Lay de la gallina
#
#  Añádelo en la StateMachine de la vaca como nodo "Milk"
#  junto a Idle, Walk, Sleep
# =============================================================

@export var character    : CharacterBody2D
@export var animation    : AnimatedSprite2D
@export var milk_spawn   : Marker2D   # arrastra el MilkSpawnPoint aquí

const MILK_SCENE := preload("res://Scenes/Items/milk.tscn")

# TEMPORAL: usa "idle" mientras no tengas animación de dar leche.
# Cuando la crees, cambia esto al nombre real (ej: "milk")
const MILK_ANIMATION_NAME : String = "idle"
const MILK_DURATION_FALLBACK : float = 1.0

var _finished : bool = false
var _timer    : float = 0.0

# =============================================================
func _on_enter() -> void:
	_finished = false
	_timer = 0.0

	if animation.sprite_frames.has_animation(MILK_ANIMATION_NAME):
		animation.play(MILK_ANIMATION_NAME)
		if not animation.sprite_frames.get_animation_loop(MILK_ANIMATION_NAME):
			if not animation.animation_finished.is_connected(_on_animation_finished):
				animation.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

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

	if animation.sprite_frames.get_animation_loop(MILK_ANIMATION_NAME):
		_timer += delta
		if _timer >= MILK_DURATION_FALLBACK and not _finished:
			_spawn_milk()
			_finished = true

func _on_next_transitions() -> void:
	if _finished:
		transition.emit("idle")

# =============================================================
func _on_animation_finished() -> void:
	if _finished:
		return
	_spawn_milk()
	_finished = true

func _spawn_milk() -> void:
	var pos : Vector2 = milk_spawn.global_position if milk_spawn else character.global_position
	_instantiate_milk(pos)

func _instantiate_milk(pos: Vector2) -> void:
	var milk = MILK_SCENE.instantiate()
	var world_parent : Node = character.get_parent()
	world_parent.add_child(milk)
	milk.global_position = pos
	milk.z_index = 5
