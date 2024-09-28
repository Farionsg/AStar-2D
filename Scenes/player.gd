extends CharacterBody2D

# @onready variables listas antes de que se cree el juego
@onready var animated_sprite = $AnimatedSprite2D
@onready var world = get_parent()

# Velocidad del jugador
@export var speed := 200.0

var idle = 0 # La use para saber en que direccion poner la idle animation
var satanas = Vector2.ZERO # La quiero usar para mostrar las animaciones de movimiento correctas
var ejeX = 0
var ejeY = 0

# Aqui guarda el camino que seguira en el A*
var path = []
var current_target_index = 0

func _process(delta):
	## Lo que necesita para moverse solo hacia el objetivo owo
	if path.size() > 0 and current_target_index < path.size():
		var target = world.tilemap.map_to_local(path[current_target_index])
		var direction = (target - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		animar(direction)		
		if global_position.distance_to(target) < 5:
			current_target_index += 1
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		animated_sprite.animation = "idleDown"
		
func animar(direction: Vector2):
	animated_sprite.play()
	if direction.x == ejeX:		
		if direction.x > 0:
			animated_sprite.animation = "WalkR"
		elif direction.x < 0:
			animated_sprite.animation = "WalkL"
	if direction.y == ejeY:
		if direction.y > 0:
			animated_sprite.animation = "WalkD"
		elif direction.y < 0:
			animated_sprite.animation = "WalkU"
	ejeX = direction.x
	ejeY = direction.y

				
func move_to_book():
	# Obtener posición actual del jugador
	var start = world.tilemap.local_to_map(global_position)
	var end = world.libro_position

	# Generar el camino usando AStar
	path = world.astar.get_point_path(start.x + start.y * world.MAP_WIDTH, end.x + end.y * world.MAP_WIDTH)
	current_target_index = 0
	##----------------------¿¿¿COMO ENCUENTRA EL CAMINO MAS RAPIDO????------------------------------
	## Veras la clase ASTAR de Godot se engarga completamente de eso. Una vez que le tenemos en nodos
	## todos los puntos en la clase "world" podemos generar el camino con "get_point_path" el cual
	## generara el camino con los valores que queramos osea = En que coordenadas inicia y cuales
	## son las coordenadas del objetivo. ASTAR tmabien cuenta con metodos para calcular el costo
	## de los nodos que tiene alrededor, si cambiamos el costo de ciertas tiles lo mostraria y 
	## calcularia en base a eso owo.
