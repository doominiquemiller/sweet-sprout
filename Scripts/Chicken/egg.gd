extends Area2D

const SELL_VALUE : int = 15
var can_pickup : bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	monitoring = true
	print("[Egg] listo, monitoring=", monitoring, " layer=", collision_layer, " mask=", collision_mask)

func _unhandled_input(event: InputEvent) -> void:
	if can_pickup and event.is_action_pressed("interact"):
		print("[Egg] Tecla interact detectada, can_pickup=true → llamando _pickup()")
		_pickup()

func _on_body_entered(body: Node) -> void:
	print("[Egg] body_entered: ", body.name, " | grupos: ", body.get_groups())
	if body.is_in_group("player") or body.name == "Player":
		can_pickup = true
		print("[Egg] >>> can_pickup activado <<<")

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Player":
		can_pickup = false
		print("[Egg] can_pickup desactivado (jugador se alejó)")

func _pickup() -> void:
	can_pickup = false
	
	# CORREGIDO: Muestra el estado del inventario global antes de añadir
	var global_items = Global.inventory_data if "inventory_data" in Global else {}
	print("[Egg] Antes de add_item, Global.inventory_data = ", global_items)
	
	# CORREGIDO: Se añade el huevo usando el Autoload Global
	Global.add_item("egg", 1)
	
	print("[Egg] Después de add_item, Global.inventory_data = ", global_items)
	queue_free()
