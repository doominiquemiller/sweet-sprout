extends Node2D

# =============================================================
#  FenceDoor
#  Frame 0     = cerrada (inicio)
#  Frame 1-2   = abriéndose
#  Frame 3-4   = abierta
#  Frame 5-6   = cerándose
#  Frame 7     = cerrada (final)
# =============================================================

@onready var sprite         : AnimatedSprite2D = $AnimatedSprite2D
@onready var collision      : CollisionShape2D = $CollisionShape2D
@onready var area           : Area2D           = $Area2D
@onready var interact_label : Label            = $InteractLabel

enum DoorState { CLOSED, OPENING, OPEN, CLOSING }

var state         : DoorState = DoorState.CLOSED
var player_nearby : bool      = false

var _frame_timer  : float = 0.0
const FRAME_DURATION : float = 1.0 / 3.0

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	area.monitoring = true

	sprite.play("door")
	sprite.pause()
	sprite.frame = 0

	interact_label.visible = false
	interact_label.text = "[F] Abrir"

func _process(delta: float) -> void:
	match state:
		DoorState.OPENING:
			_advance_frames(delta, 3, DoorState.OPEN)
		DoorState.CLOSING:
			_advance_frames(delta, 7, DoorState.CLOSED)

# from_frame ya no se usa, lo quitamos del parámetro
func _advance_frames(delta: float, to_frame: int, next_state: DoorState) -> void:
	_frame_timer += delta
	if _frame_timer >= FRAME_DURATION:
		_frame_timer = 0.0
		if sprite.frame < to_frame:
			sprite.frame += 1
		else:
			state = next_state
			_on_state_reached(next_state)

func _on_state_reached(new_state: DoorState) -> void:
	match new_state:
		DoorState.OPEN:
			sprite.frame = 3
		DoorState.CLOSED:
			sprite.frame = 7
			collision.set_deferred("disabled", false)

func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby:
		return
	if event.is_action_pressed("interact"):
		_toggle_door()

func _toggle_door() -> void:
	match state:
		DoorState.CLOSED:
			_open_door()
		DoorState.OPEN:
			_close_door()

func _open_door() -> void:
	state = DoorState.OPENING
	_frame_timer = 0.0
	sprite.frame = 1
	collision.set_deferred("disabled", true)
	interact_label.text = "[F] Cerrar"

func _close_door() -> void:
	state = DoorState.CLOSING
	_frame_timer = 0.0
	sprite.frame = 5
	interact_label.text = "[F] Abrir"

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		interact_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		interact_label.visible = false
		if state == DoorState.OPEN or state == DoorState.OPENING:
			_close_door()
