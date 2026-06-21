extends Control

# =============================================================
#  InventorySlot — Un slot individual de la grilla
#
#  Jerarquía:
#  InventorySlot (Control) ← este script
#  ├─ SlotBg (TextureRect)       ← slot vacio.png / slot resaltado.png
#  ├─ ItemIcon (TextureRect)     ← icono del item (oculto si vacío)
#  └─ CountBadge (Control)
#     ├─ CountCircle (ColorRect o Sprite2D — círculo de fondo)
#     └─ CountLabel (Label)      ← "3"
# =============================================================

@onready var slot_bg     : TextureRect = $SlotBg
@onready var item_icon   : TextureRect = $ItemIcon
@onready var count_badge : Control     = $CountBadge
@onready var count_label : Label       = $CountBadge/CountLabel

const TEX_SLOT_EMPTY      := preload("res://Assets/Inventory/slot vacio.png")
const TEX_SLOT_HIGHLIGHT  := preload("res://Assets/Inventory/slot resaltado.png")

var is_empty : bool = true

func _ready() -> void:
	slot_bg.texture = TEX_SLOT_EMPTY
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	set_empty()

# =============================================================
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

# =============================================================
func _on_mouse_entered() -> void:
	slot_bg.texture = TEX_SLOT_HIGHLIGHT

func _on_mouse_exited() -> void:
	slot_bg.texture = TEX_SLOT_EMPTY
