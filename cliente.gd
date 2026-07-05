extends CharacterBody2D

signal customer_left

var player_near = false
var order = "bread"


func _ready():
	$Label.text = "F para interactuar"

func _process(delta):

	if player_near and Input.is_action_just_pressed("interact"):

		var player = get_tree().get_first_node_in_group("player")

		if $Label.text == "":
			$Label.text = "Quiero Pan."
			return

		if Global.has_item(order, 1):

			Global.remove_item(order, 1)

			# Dar dinero aquí

			customer_left.emit()
			queue_free()
		else:
			$Label.text = "No tienes mi pan."
			


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_near = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
