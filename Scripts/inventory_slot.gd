extends Control

@onready var slot_bg     : TextureRect = $SlotBg
@onready var item_icon   : TextureRect = $ItemIcon
@onready var count_badge : Control     = $CountBadge
@onready var count_label : Label       = $CountBadge/CountCircle/CountLabel

const TEX_SLOT_EMPTY      := preload("res://Assets/Inventory/slot vacio.png")
const TEX_SLOT_HIGHLIGHT  := preload("res://Assets/Inventory/slot resaltado.png")

var is_empty : bool = true
var mi_item_id : String = ""
var esta_seleccionado_por_teclado : bool = false

func _ready() -> void:
	slot_bg.texture = TEX_SLOT_EMPTY
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	set_empty()

func set_item(icon: Texture2D, count: int) -> void:
	is_empty = false
	item_icon.visible = true
	item_icon.texture = icon

	if count > 1:
		count_badge.visible = true
		count_label.text = str(count)
	else:
		count_badge.visible = false

func set_empty() -> void:
	is_empty = true
	item_icon.visible = false
	count_badge.visible = false

# Control de resalte por teclado
func marcar_como_seleccionado(activado: bool) -> void:
	esta_seleccionado_por_teclado = activado
	if esta_seleccionado_por_teclado:
		slot_bg.texture = TEX_SLOT_HIGHLIGHT
	else:
		# Solo regresa a vacío si el puntero del mouse tampoco está encima
		if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
			slot_bg.texture = TEX_SLOT_EMPTY

func _on_mouse_entered() -> void:
	slot_bg.texture = TEX_SLOT_HIGHLIGHT

func _on_mouse_exited() -> void:
	if not esta_seleccionado_por_teclado:
		slot_bg.texture = TEX_SLOT_EMPTY
