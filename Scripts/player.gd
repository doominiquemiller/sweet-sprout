extends CharacterBody2D

# Velocidad de caminata del personaje en píxeles por segundo
@export var velocidad: float = 120.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# 🛠️ SOLUCIÓN AL CONGELAMIENTO:
	# Forzamos a este nodo a procesarse SIEMPRE, incluso si el mundo o el reloj tiran un get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(_delta: float) -> void:
	# Obtener el vector de dirección desde el Input Map
	var direccion : Vector2 = Input.get_vector("left", "right", "up", "down")
	
	# Control de movimiento básico y fluido
	if direccion != Vector2.ZERO:
		velocity = direccion.normalized() * velocidad
	else:
		velocity = velocity.move_toward(Vector2.ZERO, velocidad)
	
	# Mover al personaje aplicando colisiones físicas en el mapa
	move_and_slide()
	
	# Gestionar el cambio visual de estados y direcciones
	actualizar_animacion_8_vias(direccion)

func actualizar_animacion_8_vias(direccion: Vector2) -> void:
	# Si el personaje no se está moviendo, pausamos la animación en el frame actual
	if direccion == Vector2.ZERO:
		if sprite.is_playing():
			sprite.stop()
		return
		
	# Si se está moviendo pero la animación estaba pausada, le damos play
	if not sprite.is_playing():
		sprite.play()

	# Calculamos el ángulo exacto del movimiento en grados (-180° a 180°)
	var angulo : float = rad_to_deg(direccion.angle())
	
	# Mapeo preciso en cuadrantes de 45° para las 8 direcciones (Sin usar flip_h)
	if angulo > -22.5 and angulo <= 22.5:
		sprite.animation = "right"
	elif angulo > 22.5 and angulo <= 67.5:
		sprite.animation = "down_right"
	elif angulo > 67.5 and angulo <= 112.5:
		sprite.animation = "down"
	elif angulo > 112.5 and angulo <= 157.5:
		sprite.animation = "down_left"
	elif angulo > 157.5 or angulo <= -157.5:
		sprite.animation = "left"
	elif angulo > -157.5 and angulo <= -112.5:
		sprite.animation = "up_left"
	elif angulo > -112.5 and angulo <= -67.5:
		sprite.animation = "up"
	elif angulo > -67.5 and angulo <= -22.5:
		sprite.animation = "up_right"
