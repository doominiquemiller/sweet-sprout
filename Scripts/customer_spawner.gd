extends Node

@export var customer_scene: PackedScene
@export var spawn_point: Node2D

const SPAWN_TIME = 2.0

var customer_exists = false

func _ready():
	start_timer()

func start_timer():
	await get_tree().create_timer(SPAWN_TIME).timeout

	if !customer_exists:
		spawn_customer()

func spawn_customer():
	var customer = customer_scene.instantiate()

	customer.global_position = spawn_point.global_position
	customer.customer_left.connect(_on_customer_left)

	add_child(customer)

	customer_exists = true

func _on_customer_left():
	customer_exists = false
	start_timer()
