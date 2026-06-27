extends Node2D

@export var soil_sprite  : Sprite2D = null
@export var plant_node   : AnimatedSprite2D  = null # Arrastra aquí el nodo 'DynamicCrop'
@export var label        : Label   = null

var is_tilled  : bool = false
var is_watered : bool = false
var is_planted : bool = false
var player_present : bool = false

# Rutas de tus texturas de suelo (cámbialas por tus rutas reales)
var tex_normal  = preload("res://Assets/Plants/dirt_normal.png")
var tex_tilled  = preload("res://Assets/Plants/dirt_tilled.png")
var tex_watered = preload("res://Assets/Plants/dirt_watered.png")

func _ready() -> void:
	add_to_group("crop_spaces")
	if label: label.visible = false
	call_deferred("_update_plots")

func _update_plots() -> void:
	# 1. Cambiar textura del suelo fija
	if soil_sprite:
		if is_watered: soil_sprite.texture = tex_watered
		elif is_tilled: soil_sprite.texture = tex_tilled
		else: soil_sprite.texture = tex_normal
	
	# 2. Comunicar estado a la planta
	if plant_node and plant_node.has_method("update_crop_visuals"):
		plant_node.update_crop_visuals(is_planted)
		
	if label: label.text = "[F] Arar" if not is_tilled else "[F] Interactuar"

# --- Lógica de Interacción ---
func _on_area_2d_body_entered(body):
	if body.is_in_group("player"): player_present = true
	if label: label.visible = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"): player_present = false
	if label: label.visible = false

func _unhandled_input(event):
	if player_present and event.is_action_pressed("interact"):
		# Aquí va tu lógica de herramientas (Azada/Regadera/Semillas)
		# ...
		_update_plots()
