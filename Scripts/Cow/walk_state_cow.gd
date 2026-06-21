extends State

# =============================================================
#  WalkState para la vaca — con NavigationAgent2D
#  Igual estructura que la gallina, con chequeo de should_give_milk
# =============================================================

@export var character: NonPlayableCharacter
@export var animation: AnimatedSprite2D
@export var navigation: NavigationAgent2D
@export var min_speed: float = 5.0
@export var max_speed: float = 10.0

var speed: float

func _ready() -> void:
	navigation.velocity_computed.connect(on_safe_velocity_computed)
	call_deferred("character_setup")

func character_setup() -> void:
	await get_tree().physics_frame
	set_movement_target()

func set_movement_target() -> void:
	var target_position: Vector2 = NavigationServer2D.map_get_random_point(navigation.get_navigation_map(), navigation.navigation_layers, false)
	navigation.target_position = target_position
	speed = randf_range(min_speed, max_speed)

func _on_process(_delta : float) -> void:
	pass

func _on_physics_process(_delta : float) -> void:
	if navigation.is_navigation_finished():
		character.current_walk_cycle += 1
		set_movement_target()
		return

	var target_position: Vector2 = navigation.get_next_path_position()
	var target_direction: Vector2 = character.global_position.direction_to(target_position)
	animation.flip_h = target_direction.x < 0

	var velocity: Vector2 = target_direction * speed

	if navigation.avoidance_enabled:
		navigation.velocity = velocity
	else:
		character.velocity = velocity
		character.move_and_slide()

func on_safe_velocity_computed(safe_velocity: Vector2) -> void:
	character.velocity = safe_velocity
	character.move_and_slide()

func _on_next_transitions() -> void:
	# Prioridad 1: si debe dar leche, interrumpe la caminata
	if character.get("should_give_milk") == true:
		character.set("should_give_milk", false)
		character.velocity = Vector2.ZERO
		transition.emit("milk")
		return

	if character.current_walk_cycle == character.walk_cycle:
		character.velocity = Vector2.ZERO
		transition.emit("idle")

func _on_enter() -> void:
	animation.play("walk")
	character.current_walk_cycle = 0

func _on_exit() -> void:
	animation.stop()
