extends Node2D

# =============================================================
#  FruitTree — Árbol de frutas
#
#  Jerarquía en fruit_tree.tscn:
#  FruitTree (Node2D) ← este script
#  ├─ AnimatedSprite2D
#  ├─ CollisionShape2D
#  └─ HarvestArea (Area2D)
#     └─ CollisionShape2D
# =============================================================

@onready var sprite       : AnimatedSprite2D = $AnimatedSprite2D
@onready var harvest_area : Area2D           = $HarvestArea

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

var fruit_type     : String = ""
var is_ready       : bool   = false
var is_planted     : bool   = false
var _player_nearby : bool   = false

signal fruit_harvested(fruit_type: String)

# =============================================================
func _ready() -> void:
	harvest_area.body_entered.connect(_on_body_entered)
	harvest_area.body_exited.connect(_on_body_exited)
	harvest_area.monitoring = true
	add_to_group("fruit_trees")

func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby and is_ready and event.is_action_pressed("interact"):
		_harvest()

# =============================================================
#  PLANTAR
# =============================================================
func plant(type: String) -> void:
	if not ANIM_MAP.has(type):
		push_error("[FruitTree] Tipo desconocido: %s" % type)
		return

	fruit_type = type
	is_planted  = true
	is_ready    = false

	var anim_name : String = ANIM_MAP[fruit_type]
	sprite.play(anim_name)
	sprite.pause()
	sprite.frame = 0

	print("[FruitTree] Plantado: %s — frame 0/%d" % [
		fruit_type,
		sprite.sprite_frames.get_frame_count(anim_name) - 1
	])

# =============================================================
#  AL DORMIR — avanza 1 frame
# =============================================================
func on_day_passed() -> void:
	if not is_planted or is_ready:
		return

	var anim_name  : String = ANIM_MAP[fruit_type]
	var last_frame : int    = sprite.sprite_frames.get_frame_count(anim_name) - 1

	if sprite.frame < last_frame:
		sprite.frame += 1

	if sprite.frame >= last_frame:
		is_ready = true
		print("[FruitTree] %s listo para cosechar!" % fruit_type)
	else:
		print("[FruitTree] %s — frame %d/%d" % [fruit_type, sprite.frame, last_frame])

# =============================================================
#  COSECHAR
# =============================================================
func _harvest() -> void:
	var item_id : String = FRUIT_ITEM[fruit_type]
	Inventory.add_item(item_id, 1)
	emit_signal("fruit_harvested", fruit_type)

	# Resetear al frame 0 después de cosechar
	is_ready   = false
	sprite.frame = 0
	print("[FruitTree] Cosechado: %s" % item_id)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_nearby = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
