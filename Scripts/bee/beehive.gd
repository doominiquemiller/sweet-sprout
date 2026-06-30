extends Node2D

# =============================================================
#  Beehive — Colmena Autónoma (Tiempo Real - 4 Minutos)
# =============================================================

@onready var area            : Area2D   = $Area2D
@onready var honey_indicator : Sprite2D = $HoneyIndicator

const TEX_HONEY := preload("res://Assets/Objects/Honey_item.png")

const ICON_BASE_Y   : float = -10.0
const ICON_SPAWN_Y  : float = -16.0

var _honey_count   : int  = 0
var _player_nearby : bool = false

const MAX_HONEY_STORAGE : int = 2 

# Temporizador para la producción en tiempo real
var production_timer : Timer

# =============================================================
func _enter_tree() -> void:
	if not is_in_group("beehives"):
		add_to_group("beehives")

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	area.monitoring = true

	honey_indicator.texture = TEX_HONEY
	honey_indicator.visible = false
	honey_indicator.position = Vector2(0, ICON_BASE_Y)

	# Configuramos el Timer mediante código
	production_timer = Timer.new()
	production_timer.one_shot = false # Ciclo infinito (cada 4 minutos intenta producir)
	production_timer.autostart = true
	production_timer.timeout.connect(_on_production_timer_timeout)
	add_child(production_timer)
	
	# 4 minutos reales = 240 segundos
	production_timer.start(240.0)
	print("[Beehive] Temporizador de producción de miel iniciado: 4 minutos reales.")

# =============================================================
#  SISTEMA DE PRODUCCIÓN EN TIEMPO REAL
# =============================================================
func _on_production_timer_timeout() -> void:
	_trigger_production()

func _trigger_production() -> void:
	# Comprobamos si la colmena ya alcanzó el límite de almacenamiento
	if _honey_count >= MAX_HONEY_STORAGE:
		print("[Beehive] Producción lista, pero la colmena ya está llena (%d/%d)." % [_honey_count, MAX_HONEY_STORAGE])
		return
		
	_honey_count = min(_honey_count + 1, MAX_HONEY_STORAGE)
	
	# Aseguramos visibilidad y estado inicial antes del Tween
	honey_indicator.visible = true
	honey_indicator.modulate.a = 1.0
	honey_indicator.position = Vector2(0, ICON_BASE_Y)
	
	var tween = create_tween()
	tween.tween_property(honey_indicator, "position", Vector2(0, ICON_SPAWN_Y), 0.4).set_ease(Tween.EASE_OUT)
	print("[Beehive] ¡Éxito! Nueva miel producida. Miel almacenada en colmena: %d/%d" % [_honey_count, MAX_HONEY_STORAGE])

# =============================================================
#  RECOGER MIEL
# =============================================================
func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby and _honey_count > 0 and event.is_action_pressed("interact"):
		_collect_honey()

func _collect_honey() -> void:
	var amount_to_give : int = _honey_count
	_honey_count = 0

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(honey_indicator, "position", Vector2(0, ICON_BASE_Y + 4), 0.2).set_ease(Tween.EASE_IN)
	tween.tween_property(honey_indicator, "modulate:a", 0.0, 0.2)
	await tween.finished

	honey_indicator.visible = false
	honey_indicator.position = Vector2(0, ICON_BASE_Y)
	honey_indicator.modulate.a = 1.0

	Inventory.add_item("honey", amount_to_give)
	print("[Beehive] Cosechado: %d de miel. Total Inventario: %d" % [amount_to_give, Inventory.get_item_count("honey")])

# =============================================================
#  DETECCIÓN DEL JUGADOR
# =============================================================
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Player":
		_player_nearby = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Player":
		_player_nearby = false
