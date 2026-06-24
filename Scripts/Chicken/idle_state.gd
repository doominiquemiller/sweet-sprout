extends State

@export var character              : NonPlayableCharacter
@export var animation              : AnimatedSprite2D
@export var idle_state_time_intervarl : float = 4.0

@onready var idle_state_timer : Timer = Timer.new()

var idle_state_timeout : bool = false

func _ready() -> void:
	idle_state_timer.wait_time = idle_state_time_intervarl
	idle_state_timer.timeout.connect(on_idle_state_timeout)
	add_child(idle_state_timer)

func _on_process(_delta: float) -> void:
	pass

func _on_physics_process(_delta: float) -> void:
	pass

func _on_next_transitions() -> void:
	if character and character.get("should_lay_egg") == true:
		character.set("should_lay_egg", false)
		transition.emit("lay")
		return

	if idle_state_timeout:
		transition.emit("walk")

func _on_enter() -> void:
	animation.play("idle")
	idle_state_timeout = false
	idle_state_timer.start()

func _on_exit() -> void:
	animation.stop()
	idle_state_timer.stop()

func on_idle_state_timeout() -> void:
	idle_state_timeout = true
