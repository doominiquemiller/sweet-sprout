extends Node2D

# =============================================================
#  FruitBush — Versión Tiempo Real (2 Minutos)
# =============================================================

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

const ANIM_MAP : Dictionary = {
	"blackberry": "blackberry",
	"blueberry":  "blueberry",
	"raspberry":  "raspberry",
}

const FRUIT_ITEM : Dictionary = {
	"blackberry": "blackberry_item",
	"blueberry":  "blueberry_item",
	"raspberry":  "raspberry_item",
}

var bush_type  : String = ""
var is_planted : bool   = false
var is_ready   : bool   = false

# Timer interno para controlar el crecimiento
var growth_timer : Timer

func _ready() -> void:
	add_to_group("planted_bushes")
	z_index = 1
	
	# Creamos y configuramos el Timer mediante código para que sea independiente
	growth_timer = Timer.new()
	growth_timer.one_shot = true
	growth_timer.timeout.connect(_on_growth_timer_timeout)
	add_child(growth_timer)

func plant(type: String) -> void:
	if not ANIM_MAP.has(type):
		return

	bush_type = type
	is_planted = true
	is_ready = false

	sprite.animation = ANIM_MAP[bush_type]
	sprite.frame = 0 
	sprite.stop()

	# Iniciamos la primera fase: 60 segundos (1 minuto) para pasar a Frame 1
	growth_timer.start(60.0)
	print("[FruitBush] %s plantado. Crecimiento en tiempo real iniciado (Fase 1)." % bush_type)

# Maneja la evolución automática del arbusto por tiempo real
func _on_growth_timer_timeout() -> void:
	if not is_planted:
		return

	if sprite.frame == 0:
		# Pasa de Brote a Arbusto Verde (Frame 1)
		sprite.frame = 1
		print("[FruitBush] %s creció a arbusto verde (Frame 1). Esperando 1 minuto más para dar frutos." % bush_type)
		# Iniciamos la segunda fase: 60 segundos más (1 minuto) para dar frutos (Total: 2 minutos)
		growth_timer.start(60.0)
		
	elif sprite.frame == 1 and not is_ready:
		# Pasa de Arbusto Verde a Dar Frutos (Frame 2)
		sprite.frame = 2
		is_ready = true
		print("[FruitBush] ¡El arbusto de %s dio frutos en tiempo real! (Frame 2)" % bush_type)

func _ready_to_harvest() -> bool:
	return is_ready

# Función pública para ejecutar la cosecha desde el BushSpace
func collect_harvest() -> void:
	var item_id : String = FRUIT_ITEM[bush_type]
	Inventory.add_item(item_id, 1)
	
	# Reset de estados
	is_ready = false
	sprite.frame = 1 # Vuelve al estado de arbusto verde
	print("[FruitBush] Cosechado: %s. Volviendo al frame 1." % item_id)
	
	# Reinicia automáticamente el contador de 1 minuto para volver a dar frutos
	growth_timer.start(60.0)
	print("[FruitBush] %s volverá a dar frutos en 1 minuto real." % bush_type)
