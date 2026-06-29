extends State

@export var character  : CharacterBody2D
@export var animation  : AnimatedSprite2D
@export var egg_spawn  : Marker2D

const EGG_SCENE := preload("res://Scenes/Animals/egg.tscn")

const LAY_ANIMATION_NAME : String = "idle"
const LAY_DURATION_FALLBACK : float = 1.0

var _finished : bool = false
var _timer    : float = 0.0

func _on_enter() -> void:
	_finished = false
	_timer = 0.0

	if animation.sprite_frames.has_animation(LAY_ANIMATION_NAME):
		animation.play(LAY_ANIMATION_NAME)
		if not animation.sprite_frames.get_animation_loop(LAY_ANIMATION_NAME):
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

	if animation.sprite_frames.get_animation_loop(LAY_ANIMATION_NAME):
		_timer += delta
		if _timer >= LAY_DURATION_FALLBACK and not _finished:
			_spawn_egg()
			_finished = true

func _on_next_transitions() -> void:
	if _finished:
		transition.emit("idle")

func _on_animation_finished() -> void:
	if _finished:
		return
	_spawn_egg()
	_finished = true

func _spawn_egg() -> void:
	var pos : Vector2 = egg_spawn.global_position if egg_spawn else character.global_position
	_instantiate_egg(pos)

func _instantiate_egg(pos: Vector2) -> void:
	var egg = EGG_SCENE.instantiate()
	var world_parent : Node = character.get_parent()
	world_parent.add_child(egg)
	egg.global_position = pos
	egg.z_index = 5
