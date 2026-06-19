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
	if body.is_in_group("player"):
		can_pickup = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		can_pickup = false

func _pickup() -> void:
	can_pickup = false
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("add_to_inventory"):
		player.add_to_inventory("egg", 1)
	queue_free()
