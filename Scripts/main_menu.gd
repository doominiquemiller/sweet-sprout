extends Control

# Ajusta esta ruta a donde esté tu escena del mundo
const WORLD_SCENE := "res://World/world.tscn"

@onready var sonido_boton = $SonidoBoton
@onready var sonido_hover = $SonidoHover

func _ready() -> void:
	# Conexiones para los clics
	$Fondo/VBoxContainer/Jugar.pressed.connect(_on_jugar_pressed)
	$Fondo/VBoxContainer/Opciones.pressed.connect(_on_opciones_pressed)
	$Fondo/VBoxContainer/Salir.pressed.connect(_on_salir_pressed)
	
	# Conexiones para el hover (pasar el cursor)
	$Fondo/VBoxContainer/Jugar.mouse_entered.connect(_on_boton_hover)
	$Fondo/VBoxContainer/Opciones.mouse_entered.connect(_on_boton_hover)
	$Fondo/VBoxContainer/Salir.mouse_entered.connect(_on_boton_hover)

func _on_boton_hover() -> void:
	sonido_hover.play()

func _on_jugar_pressed() -> void:
	sonido_boton.play()
	await sonido_boton.finished
	get_tree().change_scene_to_file(WORLD_SCENE)

func _on_opciones_pressed() -> void:
	sonido_boton.play()
	print("[MainMenu] Abrir opciones (aún no implementado)")

func _on_salir_pressed() -> void:
	sonido_boton.play()
	await sonido_boton.finished
	get_tree().quit()
