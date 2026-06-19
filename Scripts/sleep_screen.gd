extends CanvasLayer

# --- Señales y Referencias ---
signal sleep_confirmed

var clock: Node = null

# Nodos hijos (Asegúrate de que los nombres coincidan en tu árbol de la interfaz)
@onready var background  : ColorRect   = $Background
@onready var menu_panel  : TextureRect = $MenuPanel
@onready var label       : Label       = $MenuPanel/Label
@onready var accept_btn  : TextureButton = $MenuPanel/AcceptButton # Cambiado a TextureRect si usas botones personalizados

func _ready() -> void:
	# Forzamos a que ignore la pausa del juego para que el botón responda
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Inicializamos la interfaz invisible y transparente al arrancar
	visible = false
	background.modulate.a = 0.0
	menu_panel.modulate.a = 0.0
	menu_panel.scale = Vector2(0.7, 0.7) # Preparado para el efecto de escala

## Esta función la llama el mundo (world.gd) a las 10:00 PM
func show_screen() -> void:
	visible = true
	
	# Buscamos la variable de día correcta en tu clock_ui (current_day)
	if clock and "current_day" in clock:
		label.text = "¡Fin del Día %d!\n¿Quieres ir a dormir?" % clock.current_day
	else:
		label.text = "¡Fin del Día!\n¿Quieres ir a dormir?"
		
	# --- ANIMACIÓN COZY DE ENTRADA (Tween) ---
	var tween = create_tween().set_parallel(true)
	
	# 1. El fondo oscuro aparece suavemente en 0.5 segundos
	tween.tween_property(background, "modulate:a", 0.6, 0.5).set_trans(Tween.TRANS_SINE)
	
	# 2. El cartel aparece con un desvanecimiento y rebote elástico adorable
	tween.tween_property(menu_panel, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(menu_panel, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## CONECTA ESTO A LA SEÑAL DEL BOTÓN DE CONFIRMAR (Al hacer clic)
func _on_accept_button_pressed() -> void:
	# Animación rápida de salida antes de cambiar el día
	var tween = create_tween().set_parallel(true)
	tween.tween_property(background, "modulate:a", 0.0, 0.3)
	tween.tween_property(menu_panel, "modulate:a", 0.0, 0.3)
	tween.tween_property(menu_panel, "scale", Vector2(0.8, 0.8), 0.3)
	
	# Esperamos a que la animación termine antes de avanzar el tiempo
	await tween.finished
	visible = false
	
	# Avisamos al mundo para restablecer todo
	sleep_confirmed.emit()
