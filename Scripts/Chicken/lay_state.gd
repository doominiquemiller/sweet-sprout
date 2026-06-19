extends State

@export var character  : CharacterBody2D
@export var animation  : AnimatedSprite2D
@export var egg_spawn  : Marker2D   # arrastra el EggSpawnPoint aquí

const EGG_SCENE := preload("res://Scenes/Items/egg.tscn")

var _finished : bool = false

# =============================================================
func _on_enter() -> void:
	_finished = false
	animation.play("lay")
	# Esperamos a que termine la animación para soltar el huevo
	animation.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func _on_exit() -> void:
	animation.stop()
	_finished = false

func _on_process(_delta: float) -> void:
	pass

func _on_physics_process(_delta: float) -> void:
	# La gallina no se mueve mientras pone el huevo
	character.velocity = Vector2.ZERO
	character.move_and_slide()

func _on_next_transitions() -> void:
	if _finished:
		transition.emit("idle")

# =============================================================
func _on_animation_finished() -> void:
	_spawn_egg()
	_finished = true

func _spawn_egg() -> void:
	var egg = EGG_SCENE.instantiate()
	character.get_parent().add_child(egg)
	egg.global_position = egg_spawn.global_position
