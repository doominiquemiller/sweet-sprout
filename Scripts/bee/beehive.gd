extends Node2D

# =============================================================
#  Beehive — Colmena que produce miel por Día
# =============================================================

@onready var area            : Area2D   = $Area2D
@onready var honey_indicator : Sprite2D = $HoneyIndicator

# Textura exclusiva del recurso
const TEX_HONEY := preload("res://Assets/Objects/Honey_item.png")

# Alturas de la burbuja ajustadas cerca del objeto
const ICON_BASE_Y   : float = -10.0
const ICON_SPAWN_Y  : float = -16.0

var _has_honey     : bool = false
var _player_nearby : bool = false

# =============================================================
func _enter_tree() -> void:
	# Registramos la colmena en su propio grupo exclusivo
	if not is_in_group("beehives"):
		add_to_group("beehives")

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	area.monitoring = true

	# Configurar el indicador visual flotante (Empieza oculto/vacío)
	honey_indicator.texture = TEX_HONEY
	honey_indicator.visible = false
	honey_indicator.position = Vector2(0, ICON_BASE_Y)

# =============================================================
#  SISTEMA DE CAMBIO DE TIEMPO (Llamado desde World.gd al dormir)
# =============================================================
func advance_production_day() -> void:
	# Si ya tiene miel sin recoger, no se acumula
	if _has_honey:
		return
		
	_has_honey = true
	honey_indicator.visible = true
	honey_indicator.modulate.a = 1.0
	honey_indicator.position = Vector2(0, ICON_BASE_Y)
	
	# Animación sutil de aparición al amanecer
	var tween = create_tween()
	tween.tween_property(honey_indicator, "position", Vector2(0, ICON_SPAWN_Y), 0.3)\
		.set_ease(Tween.EASE_OUT)
	print("[Beehive] ¡Las abejas han producido miel para hoy!")

# =============================================================
#  RECOGER MIEL
# =============================================================
func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby and _has_honey and event.is_action_pressed("interact"):
		_collect_honey()

func _collect_honey() -> void:
	_has_honey = false

	# Animación de recogida
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(honey_indicator, "position", Vector2(0, ICON_BASE_Y + 4), 0.2).set_ease(Tween.EASE_IN)
	tween.tween_property(honey_indicator, "modulate:a", 0.0, 0.2)
	await tween.finished

	honey_indicator.visible = false
	honey_indicator.position = Vector2(0, ICON_BASE_Y)
	honey_indicator.modulate.a = 1.0

	# Entrega del ítem
	Inventory.add_item("honey", 1)
	print("[Beehive] Miel recogida — total en inventario: %d" % Inventory.get_item_count("honey"))

# =============================================================
#  DETECCIÓN DEL JUGADOR
# =============================================================
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Player":
		_player_nearby = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Player":
		_player_nearby = false
