extends Node2D
class_name BaseCrop

# =============================================================
#  CROP BASE - Clase padre para todos los cultivos (Spritesheet Horizontal)
# =============================================================

# Variables exportadas que aparecerán en el Inspector
@export var crop_type: String = "wheat"
@export var stages: int = 6

# Configuración del spritesheet horizontal
@export var sprite_sheet: Texture2D  # <--- Esta línea es la que faltaba
@export var frame_width: int = 16    # Ancho de cada frame (96/6 = 16)
@export var frame_height: int = 48   # Alto de cada frame

# Variables internas
var planting_hour: float = 6.0
var is_ready: bool = false
var current_stage: int = 0
var crop_data: Dictionary = {}

# Referencias a nodos
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	add_to_group("crops")
	
	# Configurar según el tipo de cultivo
	match crop_type:
		"wheat":
			crop_data = {
				"harvest_item": "wheat",
				"harvest_count": 2
			}
		"sugar_cane":
			crop_data = {
				"harvest_item": "sugar_cane",
				"harvest_count": 3
			}
		_:
			crop_data = {
				"harvest_item": crop_type,
				"harvest_count": 1
			}
	
	# Configurar el sprite para usar spritesheet
	_setup_sprite_sheet()
	
	# Actualizar al frame inicial
	update_stage(0)

func _setup_sprite_sheet() -> void:
	if not sprite_sheet:
		print("[BaseCrop] ERROR: No se ha asignado el spritesheet")
		return
	
	if sprite:
		sprite.texture = sprite_sheet
		sprite.region_enabled = true
		
		# Configurar región para el primer frame
		var region = Rect2(
			0,                    # x (columna inicial)
			0,                    # y (fila inicial)
			frame_width,          # ancho del frame
			frame_height          # alto del frame
		)
		sprite.region_rect = region
		sprite.centered = true

func plant(plant_time: float = 6.0) -> void:
	planting_hour = plant_time
	current_stage = 0
	is_ready = false
	update_stage(0)
	print("[BaseCrop] %s plantado a las %.1f" % [crop_type, plant_time])

# Actualiza la animación según la hora actual
func update_crop(current_time: float) -> void:
	if is_ready:
		return
	
	# Calculamos el progreso desde la plantación hasta las 18:00 (6 PM)
	var total_time: float = 18.0 - planting_hour
	var elapsed_time: float = current_time - planting_hour
	
	if elapsed_time <= 0:
		update_stage(0)
		return
	
	# Calculamos en qué etapa está basado en el tiempo transcurrido
	var progress: float = elapsed_time / total_time
	var new_stage: int = min(int(progress * stages), stages - 1)
	
	if new_stage != current_stage:
		update_stage(new_stage)
		
	# Si alcanzó la última etapa, está listo para cosechar
	if new_stage == stages - 1:
		is_ready = true

func update_stage(stage: int) -> void:
	current_stage = clamp(stage, 0, stages - 1)
	
	# Actualizar sprite usando spritesheet horizontal
	if sprite and sprite_sheet:
		var region = Rect2(
			current_stage * frame_width,  # x (columna según etapa)
			0,                             # y (siempre 0 para horizontal)
			frame_width,                   # ancho
			frame_height                   # alto
		)
		sprite.region_rect = region
	
	# Si tienes AnimationPlayer, actualizar también
	if animation_player:
		if not animation_player.has_animation("grow"):
			_create_grow_animation()
		animation_player.play("grow")
		animation_player.seek(float(current_stage) / stages, true)
	
	print("[BaseCrop] %s etapa: %d/%d" % [crop_type, current_stage + 1, stages])

func _create_grow_animation() -> void:
	if not animation_player:
		return
	
	# Eliminar animación existente si la hay
	if animation_player.has_animation("grow"):
		animation_player.remove_animation("grow")
	
	# Crear nueva animación
	var anim = Animation.new()
	anim.length = stages * 0.2  # 0.2 segundos por frame
	anim.loop_mode = Animation.LOOP_NONE
	
	# Añadir track para la región del sprite
	var track_index = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_index, "Sprite2D:region_rect")
	
	# Añadir keyframes para cada etapa
	for i in range(stages):
		var time = i * 0.2
		var rect = Rect2(
			i * frame_width,  # x
			0,                # y
			frame_width,      # ancho
			frame_height      # alto
		)
		anim.track_insert_key(track_index, time, rect)
	
	# Añadir la animación al AnimationPlayer
	animation_player.add_animation("grow", anim)

func collect_harvest() -> void:
	if not is_ready:
		print("[BaseCrop] El cultivo aún no está listo")
		return
	
	var harvest_item = crop_data.get("harvest_item", crop_type)
	var harvest_count = crop_data.get("harvest_count", 1)
	
	print("[BaseCrop] Cosechando %d %s" % [harvest_count, harvest_item])
	
	# Agregar al inventario
	if Inventory.has_method("add_item"):
		Inventory.add_item(harvest_item, harvest_count)
	
	# Destruir el cultivo
	queue_free()

# Función para verificar si está listo desde afuera
func is_crop_ready() -> bool:
	return is_ready
