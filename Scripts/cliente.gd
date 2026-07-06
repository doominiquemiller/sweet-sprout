extends CharacterBody2D

signal customer_left

var player_near := false
var order_requested := false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const ORDERS = [
	{
		"id": "bread",
		"name": "Pan",
		"price": 25
	},
	{
		"id": "donut",
		"name": "Dona",
		"price": 50
	}
]

var order

func _ready():
	sprite.play("default")
	order = ORDERS.pick_random()
	$Label.visible = false
	
func _process(_delta):

	if !player_near:
		return

	if Input.is_action_just_pressed("interact"):

		# Primera interacción
		if !order_requested:
			order_requested = true
			$Label.text = "Quiero %s." % order.name
			return

		# Segunda interacción
		if Global.has_item(order.id, 1):

			Global.remove_item(order.id, 1)
			Global.add_money(order.price)

			customer_left.emit()
			queue_free()

		else:
			$Label.text = "No tienes mi %s." % order.name


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		if !order_requested:
			$Label.text = "F para interactuar"

		$Label.visible = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		$Label.visible = false
