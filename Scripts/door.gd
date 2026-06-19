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

# Timers para controlar qué frames reproducir
var _frame_timer  : float = 0.0
var _target_frame : int   = 0
const FRAME_DURATION : float = 1.0 / 3.0  # 3 FPS → cada frame dura ~0.33 seg

# =============================================================
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	area.monitoring = true

	# Empezar en frame 0 pausada
	sprite.play("door")
	sprite.pause()
	sprite.frame = 0

	interact_label.visible = false
	interact_label.text = "[F] Abrir"

func _process(delta: float) -> void:
	# Avanzamos manualmente los frames según el estado
	match state:
		DoorState.OPENING:
			_advance_frames(delta, 1, 2, DoorState.OPEN)
		DoorState.CLOSING:
			_advance_frames(delta, 5, 7, DoorState.CLOSED)

func _advance_frames(delta: float, from_frame: int, to_frame: int, next_state: DoorState) -> void:
	_frame_timer += delta
	if _frame_timer >= FRAME_DURATION:
		_frame_timer = 0.0
		if sprite.frame < to_frame:
			sprite.frame += 1
		else:
			# Llegamos al frame final — cambiar estado
			state = next_state
			_on_state_reached(next_state)

func _on_state_reached(new_state: DoorState) -> void:
	match new_state:
		DoorState.OPEN:
			# Quedarse en frame 3 o 4 (abierta)
			sprite.frame = 3
		DoorState.CLOSED:
			# Quedarse en frame 7 (cerrada)
			sprite.frame = 7
			collision.set_deferred("disabled", false)

# =============================================================
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
	sprite.frame = 1  # Empieza en el primer frame de apertura
	collision.set_deferred("disabled", true)
	interact_label.text = "[F] Cerrar"

func _close_door() -> void:
	state = DoorState.CLOSING
	_frame_timer = 0.0
	sprite.frame = 5  # Empieza en el primer frame de cierre
	interact_label.text = "[F] Abrir"

# =============================================================
func _on_body_entered(body: Node) -> void:
	print("Entró: ", body.name, " grupos: ", body.get_groups())
	if body.is_in_group("player"):
		player_nearby = true
		interact_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		interact_label.visible = false
		if state == DoorState.OPEN or state == DoorState.OPENING:
			_close_door()
