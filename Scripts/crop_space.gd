extends Area2D

# =============================================================
#  CropSpace — Sistema de Cultivo con Ciclo de Animaciones Exacto
# =============================================================

@onready var sprite : AnimatedSprite2D = $"../dynamic_crop/AnimatedSprite2D"
@onready var label  : Label            = $"../InteractionLabel"

const FRUIT_ITEM : Dictionary = {
	"wheat":     "wheat_item",
	"sugarcane": "sugarcane.png"
}

var is_tilled   : bool = false
var is_watered  : bool = false
var is_planted  : bool = false
var is_ready    : bool = false
var crop_type   : String = ""

# Etapas del ciclo: 
# 0 = seeds, 1 = seed, 2 = grow1, 3 = grow2, 4 = grow3, 5 = fullgrow
var growth_stage   : int = 0
var harvests_done  : int = 0
const MAX_HARVESTS : int = 3

var player_inside  : bool = false

func _ready() -> void:
	add_to_group("crop_spaces")
	add_to_group("planted_crops")
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if label:
		label.visible = false
		
	if sprite:
		sprite.visible = true
	_update_visuals()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_inside = true
		if is_ready and label:
			label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_inside = false
		if label:
			label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_inside and (event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_F)):
		_process_interaction()

func _process_interaction() -> void:
	var active_tool : String = Inventory.get_item_seleccionado()

	# 1. COSECHAR CUANDO ESTÁ LISTO (Requiere obligatoriamente usar la Azada "hoe")
	if is_ready:
		if active_tool == "hoe":
			_harvest()
		else:
			print("[CropSpace] Necesitas equipar la Azada (hoe) para recolectar este cultivo.")
		return

	# 2. HERRAMIENTA: AZADA (Para labrar tierra virgen)
	if active_tool == "hoe" and not is_tilled and not is_planted:
		is_tilled = true
		_update_visuals()
		print("[CropSpace] Tierra arada listas para plantar.")
		return

	# 3. HERRAMIENTA: REGADERA (Cambia el estado a watered e influye visualmente de inmediato)
	if active_tool == "watering_can":
		if is_tilled and not is_watered:
			is_watered = true
			_update_visuals()
			print("[CropSpace] Tierra regada.")
		return

	# 4. ACCIÓN: PLANTAR SEMILLAS (Singular de inventario)
	if is_tilled and not is_planted:
		if active_tool == "wheat_seed" or active_tool == "sugarcane_seed":
			_plant_crop(active_tool)

func _update_visuals() -> void:
	if not sprite: 
		return

	# Parcela vacía o arada sin planta todavía
	if not is_planted:
		sprite.stop()
		sprite.frame = 0 
		return

	var anim_name : String = crop_type # "wheat" o "sugarcane"

	# El ciclo exacto que me pediste
	match growth_stage:
		0: anim_name += "_seeds"    # Recién plantado (wheat_seeds / sugarcane_seeds)
		1: anim_name += "_seed"     # Fase semilla
		2: anim_name += "_grow1"    # Fase brote 1
		3: anim_name += "_grow2"    # Fase brote 2
		4: anim_name += "_grow3"    # Fase brote 3
		5: anim_name += "_fullgrow" # Fase final madura

	# Si interactuaste con la regadera, se pone la variante '_watered'
	if is_watered:
		var watered_version = anim_name + "_watered"
		if sprite.sprite_frames.has_animation(watered_version):
			anim_name = watered_version

	# Reproducción en el panel del AnimatedSprite2D
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		# Plan B por si acaso usas "wheat_seed2" o similares en tu lista
		if growth_stage == 1 and sprite.sprite_frames.has_animation(crop_type + "_seed2"):
			sprite.play(crop_type + "_seed2")
		else:
			print("[CropSpace] Error: No se encontró la animación: ", anim_name)

func _plant_crop(seed_id: String) -> void:
	if Inventory.remove_item(seed_id, 1):
		crop_type = "wheat" if "wheat" in seed_id else "sugarcane"
		is_planted = true
		growth_stage = 0 # Empieza directo en "_seeds"
		is_ready = false
		_update_visuals()
		print("[CropSpace] ¡Plantado!: ", crop_type)
		
		if Inventory.get_item_count(seed_id) == 0:
			Inventory.limpiar_seleccion()

func _harvest() -> void:
	var item_to_give : String = FRUIT_ITEM.get(crop_type, "wheat_item")
	Inventory.add_item(item_to_give, 1)
	
	harvests_done += 1
	is_ready = false
	if label:
		label.visible = false

	if harvests_done < MAX_HARVESTS:
		growth_stage = 0 # Regresa al inicio del ciclo (_seeds)
		_update_visuals()
	else:
		_reset_full_space()

func _reset_full_space() -> void:
	is_planted = false
	is_ready = false
	is_watered = false
	is_tilled = false
	growth_stage = 0
	harvests_done = 0
	if label: label.visible = false
	_update_visuals()

# Control de crecimiento horario
func check_hourly_growth(hour: int) -> void:
	if not is_planted or harvests_done >= MAX_HARVESTS:
		return

	# Pausa de noche
	if hour >= 18:
		if is_ready:
			if label: label.visible = false
			is_ready = false
			growth_stage = 4 # Retrocede a grow3 si anochece
			_update_visuals()
		return

	# Requiere agua para avanzar entre etapas
	if not is_watered:
		return

	# Ahora el límite máximo de crecimiento es la etapa 5 (fullgrow)
	if growth_stage < 5:
		growth_stage += 1
		is_watered = false # Consume el agua al mutar de fase
		
		if growth_stage == 5:
			is_ready = true
			if player_inside and label:
				label.visible = true
				
		_update_visuals()
