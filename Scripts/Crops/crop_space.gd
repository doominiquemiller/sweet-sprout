extends Node2D

# =============================================================
#  CROP SPACE - Parcela para cultivos (Trigo y Caña de Azúcar)
#  PERMITE AMBOS CULTIVOS Y SEMILLA COMO PRIMERA ETAPA
# =============================================================

# Configuración del cultivo (seleccionar en el inspector)
@export var crop_type: String = "wheat"  # "wheat" o "sugar_cane"

# Spritesheets
@export var wheat_sheet: Texture2D = preload("res://Assets/Crops/wheat_sheet.png")
@export var sugar_cane_sheet: Texture2D = preload("res://Assets/Crops/sugar_cane_sheet.png")

# Configuración del spritesheet
var frame_width: int = 16
var frame_height: int = 48
var total_frames: int = 6

# Variables de estado
var is_player_inside: bool = false
var is_planted: bool = false
var planting_hour: float = 6.0
var current_stage: int = 0
var is_ready: bool = false
var crop_data: Dictionary = {}

# Tiempo simulado
var simulated_hour: float = 6.0
var time_multiplier: float = 1.0

# Referencias a nodos hijos
@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var interaction_label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Diccionario de semillas válidas (AMBAS)
const VALID_SEEDS = {
	"wheat": "wheat_seed",
	"sugar_cane": "sugarcane_seed"
}

# Nombres para mostrar
const CROP_NAMES = {
	"wheat": "Trigo",
	"sugar_cane": "Caña de Azúcar"
}

const SEED_DISPLAY_NAMES = {
	"wheat_seed": "Semilla de Trigo 🌾",
	"sugarcane_seed": "Semilla de Caña 🎋"
}

func _ready() -> void:
	add_to_group("crop_space")
	
	_setup_crop()
	_setup_sprite()
	_create_grow_animation()
	
	if detection_area:
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)
	
	if interaction_label:
		interaction_label.text = ""
		interaction_label.visible = false
	
	simulated_hour = get_game_time()
	
	print("[CropSpace] Parcela de %s lista" % crop_type)
	print("[CropSpace] Semillas aceptadas: wheat_seed, sugarcane_seed")

func _setup_crop() -> void:
	match crop_type:
		"wheat":
			crop_data = {
				"harvest_item": "wheat",
				"harvest_count": 2,
				"sheet": wheat_sheet,
				"display_name": "Trigo",
				"harvest_text": "Presiona [F] para cosechar Trigo",
				"growing_text": "Trigo creciendo...",
				"seed_name": "Semilla de Trigo"
			}
		"sugar_cane":
			crop_data = {
				"harvest_item": "sugar_cane",
				"harvest_count": 3,
				"sheet": sugar_cane_sheet,
				"display_name": "Caña de Azúcar",
				"harvest_text": "Presiona [F] para cosechar Caña de Azúcar",
				"growing_text": "Caña de Azúcar creciendo...",
				"seed_name": "Semilla de Caña de Azúcar"
			}
		_:
			print("[CropSpace] ERROR: Tipo de cultivo no válido")

func _setup_sprite() -> void:
	if not sprite:
		print("[CropSpace] ERROR: Sprite no encontrado")
		return
	
	var sheet = crop_data.get("sheet")
	if not sheet:
		print("[CropSpace] ERROR: Spritesheet no asignado")
		return
	
	sprite.texture = sheet
	sprite.region_enabled = true
	sprite.centered = true
	sprite.scale = Vector2(2.5, 2.5)
	
	# Mostrar el frame 0 (semilla plantada)
	_update_sprite_frame(0)

func _update_sprite_frame(stage: int) -> void:
	if not sprite or not sprite.texture:
		return
	
	current_stage = clamp(stage, 0, total_frames - 1)
	
	var region = Rect2(
		current_stage * frame_width,
		0,
		frame_width,
		frame_height
	)
	sprite.region_rect = region
	
	if animation_player and animation_player.has_animation("grow"):
		animation_player.play("grow")
		animation_player.seek(float(current_stage) * 0.2, true)

func _create_grow_animation() -> void:
	if not animation_player:
		return
	
	if animation_player.has_animation("grow"):
		animation_player.remove_animation("grow")
	
	var anim = Animation.new()
	anim.length = total_frames * 0.2
	anim.loop_mode = Animation.LOOP_NONE
	
	var track_index = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_index, "Sprite2D:region_rect")
	
	for i in range(total_frames):
		var time = i * 0.2
		var rect = Rect2(
			i * frame_width,
			0,
			frame_width,
			frame_height
		)
		anim.track_insert_key(track_index, time, rect)
	
	animation_player.add_animation("grow", anim)

# =============================================================
#  ACTUALIZACIÓN AUTOMÁTICA
# =============================================================
func _process(delta: float) -> void:
	if not is_planted:
		return
	
	simulated_hour += delta * 0.1 * time_multiplier
	
	if simulated_hour > 24.0:
		simulated_hour = 6.0
	
	_update_crop_growth()
	
	if is_player_inside:
		_update_interaction_label()

func _update_crop_growth() -> void:
	if is_ready:
		return
	
	var total_time: float = 18.0 - planting_hour
	var elapsed_time: float = simulated_hour - planting_hour
	
	if elapsed_time < 0:
		if simulated_hour < 6.0:
			return
		else:
			elapsed_time = simulated_hour - planting_hour
	
	if elapsed_time <= 0:
		_update_sprite_frame(0)
		return
	
	var progress: float = elapsed_time / total_time
	var new_stage: int = min(int(progress * total_frames), total_frames - 1)
	
	if new_stage != current_stage:
		_update_sprite_frame(new_stage)
		print("[CropSpace] %s etapa: %d/%d (hora: %.1f)" % [crop_type, new_stage + 1, total_frames, simulated_hour])
	
	if new_stage == total_frames - 1:
		is_ready = true
		print("[CropSpace] ¡%s está listo para cosechar!" % crop_type)

# =============================================================
#  INTERACCIÓN CON EL JUGADOR
# =============================================================
func _unhandled_input(event: InputEvent) -> void:
	if not is_player_inside:
		return
	
	if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_F):
		_handle_interaction()

func _handle_interaction() -> void:
	if is_planted:
		if is_ready:
			_harvest_crop()
		else:
			_show_interaction_message("El cultivo aún no está listo")
		return
	
	_try_plant()

# =============================================================
#  PLANTACIÓN - ACEPTA AMBAS SEMILLAS
# =============================================================
func _try_plant() -> void:
	if not Inventory:
		print("[CropSpace] ERROR: Sistema de inventario no encontrado")
		return
	
	var selected_seed = Inventory.get_item_seleccionado()
	
	if selected_seed == "" or selected_seed == null:
		_show_interaction_message("Selecciona una semilla")
		return
	
	# VERIFICAR SI LA SEMILLA ES VÁLIDA (TRIGO O CAÑA)
	var is_valid_seed = false
	var detected_crop_type = ""
	
	for crop in VALID_SEEDS:
		if selected_seed.to_lower() == VALID_SEEDS[crop].to_lower():
			is_valid_seed = true
			detected_crop_type = crop
			break
	
	if not is_valid_seed:
		_show_interaction_message("Semilla no válida para esta parcela")
		return
	
	# Verificar si tiene la semilla
	if not Inventory.has_item(selected_seed, 1):
		_show_interaction_message("No tienes %s" % SEED_DISPLAY_NAMES.get(selected_seed, selected_seed))
		Inventory.limpiar_seleccion()
		return
	
	# Si la semilla es diferente al tipo de parcela, cambiar el cultivo
	if detected_crop_type != crop_type:
		crop_type = detected_crop_type
		_setup_crop()
		_setup_sprite()
		print("[CropSpace] Cambiado a: %s" % crop_type)
	
	# Plantar el cultivo
	_plant_crop(selected_seed)

func _plant_crop(seed_id: String) -> void:
	Inventory.remove_item(seed_id, 1)
	
	is_planted = true
	is_ready = false
	current_stage = 0
	planting_hour = get_game_time()
	simulated_hour = planting_hour
	
	# La etapa 0 es la semilla plantada (no tierra arada)
	_update_sprite_frame(0)
	
	var display_name = crop_data.get("display_name", crop_type)
	_show_interaction_message("¡%s plantado!" % display_name)
	
	if not Inventory.has_item(seed_id, 1):
		Inventory.limpiar_seleccion()
	
	print("[CropSpace] %s plantado a las %.1f" % [crop_type, planting_hour])

# =============================================================
#  COSECHA
# =============================================================
func _harvest_crop() -> void:
	if not is_ready:
		_show_interaction_message("El cultivo no está listo")
		return
	
	var harvest_item = crop_data.get("harvest_item", crop_type)
	var harvest_count = crop_data.get("harvest_count", 1)
	
	# Bonus aleatorio
	var bonus_chance = 0.2
	if randf() < bonus_chance:
		harvest_count += 1
		_show_interaction_message("¡Cosecha extra! +1 %s" % harvest_item)
	
	if Inventory and Inventory.has_method("add_item"):
		Inventory.add_item(harvest_item, harvest_count)
	
	var display_name = crop_data.get("display_name", harvest_item)
	_show_interaction_message("¡Cosechados %d %s!" % [harvest_count, display_name])
	
	print("[CropSpace] Cosechados %d %s" % [harvest_count, harvest_item])
	
	_clear_crop()

func _clear_crop() -> void:
	is_planted = false
	is_ready = false
	current_stage = 0
	
	# Volver al frame 0 (semilla visible, parcela lista para plantar)
	_update_sprite_frame(0)
	
	_show_interaction_message("Parcela lista para plantar")
	print("[CropSpace] Parcela limpiada")

# =============================================================
#  LABEL DE INTERACCIÓN
# =============================================================
func _show_interaction_message(text: String) -> void:
	if not interaction_label:
		return
	
	interaction_label.text = text
	interaction_label.visible = true
	interaction_label.modulate.a = 1.0
	
	var tween = create_tween()
	tween.tween_property(interaction_label, "modulate:a", 0.0, 0.5).set_delay(2.0)
	tween.tween_callback(func(): 
		interaction_label.visible = false
		interaction_label.modulate.a = 1.0
	)

func _update_interaction_label() -> void:
	if not interaction_label or not is_player_inside:
		return
	
	if is_planted:
		if is_ready:
			interaction_label.text = crop_data.get("harvest_text", "Presiona [F] para cosechar")
			interaction_label.visible = true
		else:
			var progress = int((float(current_stage) / (total_frames - 1)) * 100)
			interaction_label.text = "%s %d%%" % [crop_data.get("growing_text", "Creciendo..."), progress]
			interaction_label.visible = true
	else:
		interaction_label.text = "Presiona [F] para plantar (Trigo o Caña)"
		interaction_label.visible = true

# =============================================================
#  DETECCIÓN DEL JUGADOR
# =============================================================
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_inside = true
		_update_interaction_label()
		print("[CropSpace] Jugador cerca de parcela")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_inside = false
		if interaction_label:
			interaction_label.visible = false

# Obtener la hora actual del juego
func get_game_time() -> float:
	if GameTime and GameTime.has_method("get_current_time"):
		return GameTime.get_current_time()
	return simulated_hour

# =============================================================
#  PRUEBA MANUAL
# =============================================================
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _update_sprite_frame(0)
			KEY_2: _update_sprite_frame(1)
			KEY_3: _update_sprite_frame(2)
			KEY_4: _update_sprite_frame(3)
			KEY_5: _update_sprite_frame(4)
			KEY_6: _update_sprite_frame(5)
			KEY_T:
				simulated_hour += 1.0
				print("[CropSpace] Tiempo: %.1f" % simulated_hour)
			KEY_P: # Forzar plantación
				var seed = "wheat_seed" if crop_type == "wheat" else "sugarcane_seed"
				_plant_crop(seed)
