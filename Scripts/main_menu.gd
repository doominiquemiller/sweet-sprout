extends Control

# Ajusta esta ruta a donde esté tu escena del mundo
const WORLD_SCENE := "res://World/world.tscn"

func _ready() -> void:
	$Fondo/VBoxContainer/Jugar.pressed.connect(_on_jugar_pressed)
	$Fondo/VBoxContainer/Opciones.pressed.connect(_on_opciones_pressed)
	$Fondo/VBoxContainer/Salir.pressed.connect(_on_salir_pressed)

func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file(WORLD_SCENE)

func _on_opciones_pressed() -> void:
	print("[MainMenu] Abrir opciones (aún no implementado)")

func _on_salir_pressed() -> void:
	get_tree().quit()
