extends Area2D

# =============================================================
#  Milk — Leche recogible en el suelo
#  Presiona [F] (interact) cerca para recogerla
#  Mismo patrón que egg.gd
# =============================================================

const SELL_VALUE : int = 25
var can_pickup : bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	monitoring = true

func _unhandled_input(event: InputEvent) -> void:
	if can_pickup and event.is_action_pressed("interact"):
		_pickup()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		can_pickup = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		can_pickup = false

func _pickup() -> void:
	can_pickup = false
	Inventory.add_item("milk", 1)
	queue_free()
