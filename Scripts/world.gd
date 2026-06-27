extends Node2D

# ==============================================================================
#  world.gd — Manteniendo tus variables intactas sin agricultura por TileMap
# ==============================================================================

# Se mantienen tus variables exportadas y configuraciones intactas por seguridad
@export var dirt_tilemap_layer : TileMapLayer 

# CORREGIDO: Evitamos el preload de un archivo inexistente asignándolo a null por defecto
@export var dynamic_crop_scene : PackedScene = null

var grid_data : Dictionary = {}
var last_player_coord : Vector2i = Vector2i(-999, -999)

const SEED_CONFIG : Dictionary = {
	"wheat_seed":      {"type": "wheat"},
	"sugarcane_seed": {"type": "sugarcane"}
}

# Coordenadas del Atlas en tu TileSet
const TILE_DIRT_NORMAL   := Vector2i(0, 0)
const TILE_DIRT_TILLED   := Vector2i(1, 0)
const TILE_DIRT_WATERED  := Vector2i(2, 0)

func _ready() -> void:
	add_to_group("world")
	print("[Mundo] Sistema inicializado. Agricultura por TileMapLayer desactivada. Control delegado a los CropPlots autónomos.")

# ==============================================================================
#  Control del Crecimiento del Huerto (Tiempo Global)
# ==============================================================================

# Llama a esta función desde tu script de Tiempo o Reloj de juego para hacer crecer las plantas autónomas
func avanzar_hora(nueva_hora: int) -> void:
	# Hace crecer de manera automática los cultivos de tus nuevos CropPlots independientes instalados en el mapa
	for crop_space in get_tree().get_nodes_in_group("crop_spaces"):
		if "dynamic_crop" in crop_space and crop_space.dynamic_crop:
			if crop_space.dynamic_crop.has_method("check_hourly_growth"):
				crop_space.dynamic_crop.check_hourly_growth(nueva_hora)
