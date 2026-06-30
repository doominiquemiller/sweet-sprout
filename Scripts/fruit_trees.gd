extends StaticBody2D

# =============================================================
#  FruitTree — Versión Tiempo Real (2 Minutos)
# =============================================================

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var harvest_area : Area2D = $HarvestArea 

const ANIM_MAP : Dictionary = {
	"apple":  "tree_apple",
	"orange": "tree_orange",
	"peach":  "tree_peach",
	"pear":   "tree_pear",
}

const FRUIT_ITEM : Dictionary = {
	"apple":  "apple",
	"orange": "orange",
	"peach":  "peach",
	"pear":   "pear",
}

var fruit_type : String = ""
var is_planted : bool   = false
var is_ready   : bool   = false

# Timer interno para controlar el crecimiento autónomo
var growth_timer : Timer

func _ready() -> void:
	add_to_group("planted_trees")
	z_index = 1
	
	# Creamos y configuramos el Timer mediante código
	growth_timer = Timer.new()
	growth_timer.one_shot = true
	growth_timer.timeout.connect(_on_growth_timer_timeout)
	add_child(growth_timer)
	
	if sprite:
		_ajustar_posicion_local()

func plant(type: String) -> void:
	if not ANIM_MAP.has(type):
		return
	fruit_type = type
	is_planted = true
	is_ready = false
	
	sprite.stop()
	sprite.animation = ANIM_MAP[fruit_type]
	sprite.frame = 0
	_actualizar_escala()

	# Iniciamos la primera fase: 60 segundos (1 minuto) para pasar a árbol joven/adulto
	growth_timer.start(60.0)
	print("[FruitTree] %s plantado. Crecimiento en tiempo real iniciado (Fase 1)." % fruit_type)

# Maneja la evolución automática por tiempo real (recorre los frames de animación)
func _on_growth_timer_timeout() -> void:
	if not is_planted:
		return

	if sprite.frame == 0:
		# Pasa de Semilla/Brote (Frame 0) a Árbol Joven (Frame 1)
		sprite.frame = 1
		print("[FruitTree] %s creció a árbol joven (Frame 1)." % fruit_type)
		_actualizar_escala()
		# En el caso del árbol, puedes hacer que pase directamente al frame 2 en otros 30-60 seg si quieres,
		# o seguir la secuencia normal. Vamos a configurar 30s para Frame 2, y 30s para frutos (Total 2 min).
		growth_timer.start(30.0)
		
	elif sprite.frame == 1:
		# Pasa de Árbol Joven (Frame 1) a Árbol Adulto sin frutas (Frame 2)
		sprite.frame = 2
		print("[FruitTree] %s creció a árbol adulto listo para producir (Frame 2)." % fruit_type)
		_actualizar_escala()
		growth_timer.start(30.0) # Últimos 30 segundos para dar fruta (Total: 120s = 2 min)

	elif sprite.frame == 2 and not is_ready:
		# Pasa de Árbol Adulto (Frame 2) a Árbol con Frutos (Frame 3)
		_spawn_fruit()

func _spawn_fruit() -> void:
	sprite.frame = 3
	is_ready = true
	_actualizar_escala()
	print("[FruitTree] ¡El árbol de %s dio frutos en tiempo real! (Frame 3)" % fruit_type)

func _actualizar_escala() -> void:
	if not sprite:
		return
	if sprite.frame == 0:
		sprite.scale = Vector2(0.5, 0.5)
	else:
		sprite.scale = Vector2(1.0, 1.0)
	
	_ajustar_posicion_local()

func _ajustar_posicion_local() -> void:
	if sprite.frame == 0:
		sprite.position = Vector2.ZERO
	else:
		sprite.position = Vector2(0, 0) # Modifica si los frames altos necesitan reajuste vertical

# Función pública llamada desde TreeSpace para cosechar
func collect_harvest() -> void:
	var item_id : String = FRUIT_ITEM[fruit_type]
	Inventory.add_item(item_id, 1)

	is_ready = false
	sprite.frame = 2 # Vuelve a árbol adulto base sin frutas (Frame 2)
	_actualizar_escala()
	print("[FruitTree] Cosechado con éxito: %s. Volviendo al frame 2." % item_id)
	
	# Reinicia automáticamente el contador para volver a producir frutas en 1 minuto real
	growth_timer.start(60.0)
	print("[FruitTree] %s volverá a dar frutos en 1 minuto real." % fruit_type)
