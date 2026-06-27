extends Node2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var is_ready : bool = false
var growth_stages = ["seeds", "seed", "grow1", "grow2", "grow3", "fullgrow"]
var current_stage = 0

func update_crop_visuals(is_planted: bool) -> void:
	self.visible = is_planted
	if is_planted and sprite:
		sprite.play("seeds") # O la animación que corresponda

func _on_growth_timer_timeout():
	if current_stage < growth_stages.size() - 1:
		current_stage += 1
		# Actualizamos la animación según la etapa
		sprite.play(growth_stages[current_stage]) 
	else:
		is_ready = true # Permitimos la cosecha

func collect_harvest():
	if is_ready:
		#1. Dar recompensa al inventario
		Inventory.add_item("wheat_item", 1)
		
		#2. Resetear el estado de la planta
		current_stage = 0
		is_ready = false
		sprite.play("empty") # O coultar el nodo
		
		# 3. Avisar al padre que ya no hay planta
		get_parent().is_planted = false
		get_parent()._update_plots()
