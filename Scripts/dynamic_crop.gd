extends Node2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var is_ready : bool = false
var growth_stages : Array = []  # Se llenará dinámicamente según el cultivo
var current_stage : int = 0
var crop_type : String = ""  # "wheat" o "sugarcane"

func update_crop_visuals(crop: String, is_planted: bool) -> void:
	self.visible = is_planted
	if is_planted:
		crop_type = crop
		current_stage = 0
		
		# Definir las 6 etapas según el tipo de cultivo
		if crop_type == "wheat":
			growth_stages = ["wheat_seeds", "wheat_seed", "wheat_grow1", "wheat_grow2", "wheat_grow3", "wheat_fullgrow"]
		elif crop_type == "sugarcane":
			growth_stages = ["sugarcane_seeds", "sugarcane_seed", "sugarcane_grow1", "sugarcane_grow2", "sugarcane_grow3", "sugarcane_fullgrow"]
		
		# Reproducir primera animación (etapa seeds)
		if sprite and growth_stages.size() > 0:
			var first_anim = growth_stages[0]
			if sprite.sprite_frames.has_animation(first_anim):
				sprite.play(first_anim)
				print("[PlantSprite] Mostrando etapa inicial: ", first_anim)
			else:
				print("[PlantSprite] ERROR: Animación no encontrada: ", first_anim)
				print("[PlantSprite] Animaciones disponibles: ", sprite.sprite_frames.get_animation_names())

func play_growth_animation(stage_index: int) -> void:
	if not sprite or not growth_stages or stage_index >= growth_stages.size():
		return
	
	current_stage = stage_index
	var anim_name = growth_stages[stage_index]
	
	print("[PlantSprite] Cambiando a etapa ", stage_index + 1, " de ", growth_stages.size(), ": ", anim_name)
	
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		print("[PlantSprite] ERROR: Animación no encontrada: ", anim_name)
		print("[PlantSprite] Animaciones disponibles: ", sprite.sprite_frames.get_animation_names())

func on_growth_timer_timeout() -> void:
	if not growth_stages or growth_stages.size() == 0:
		print("[PlantSprite] ERROR: No hay etapas de crecimiento definidas")
		return
	
	if current_stage < growth_stages.size() - 1:
		current_stage += 1
		var anim_name = growth_stages[current_stage]
		
		print("[PlantSprite] Creciendo a etapa ", current_stage + 1, " de ", growth_stages.size(), ": ", anim_name)
		
		if sprite.sprite_frames.has_animation(anim_name):
			sprite.play(anim_name)
		else:
			print("[PlantSprite] ERROR: Animación no encontrada: ", anim_name)
			print("[PlantSprite] Animaciones disponibles: ", sprite.sprite_frames.get_animation_names())
	else:
		is_ready = true
		print("[PlantSprite] ¡Cultivo listo para cosechar! Etapa final alcanzada: ", growth_stages[current_stage])

func collect_harvest() -> Dictionary:
	if is_ready:
		print("[PlantSprite] Cosechando ", crop_type)
		
		# Devolver información de la cosecha
		var harvest_info = {
			"item_id": crop_type,  # "wheat" o "sugarcane"
			"crop_type": crop_type,
			"success": true
		}
		
		# Resetear el estado de la planta
		current_stage = 0
		is_ready = false
		crop_type = ""
		growth_stages.clear()
		
		# Ocultar o mostrar animación vacía
		if sprite:
			if sprite.sprite_frames.has_animation("empty"):
				sprite.play("empty")
				print("[PlantSprite] Mostrando animación vacía")
			else:
				self.visible = false
				sprite.stop()
				print("[PlantSprite] Ocultando planta")
		
		return harvest_info
	
	print("[PlantSprite] No hay nada listo para cosechar")
	return {"success": false}

func reset_plant() -> void:
	print("[PlantSprite] Reseteando planta")
	current_stage = 0
	is_ready = false
	crop_type = ""
	growth_stages.clear()
	self.visible = false
	if sprite:
		sprite.stop()

func get_current_stage_name() -> String:
	if growth_stages and current_stage < growth_stages.size():
		return growth_stages[current_stage]
	return ""

func get_total_stages() -> int:
	return growth_stages.size()

func is_growing() -> bool:
	return not is_ready and growth_stages.size() > 0 and crop_type != ""
