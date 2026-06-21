extends Area2D

const SELL_VALUE : int = 15
var can_pickup : bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if can_pickup and event.is_action_pressed("interact"):
		_pickup()

func _on_body_entered(body: Node) -> void:
	print("[Egg] body_entered: ", body.name, " grupos: ", body.get_groups())
	if body.is_in_group("player"):
		can_pickup = true
		print("[Egg] can_pickup = true")

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		can_pickup = false

func _pickup() -> void:
	print("[Egg] _pickup() ejecutado")
	can_pickup = false
	print("[Egg] Inventory existe? ", Inventory)
	Inventory.add_item("egg", 1)
	print("[Egg] add_item llamado. Items actuales: ", Inventory.items)
	queue_free()
