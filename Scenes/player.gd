extends CharacterBody2D

# @onready variables listas antes de que se cree el juego
@onready var animated_sprite = $AnimatedSprite2D
@onready var world = get_parent()
@onready var cost_label = $Camera2D/CostLabel
@onready var up_cost_label = $Camera2D/UpCostLabel
@onready var down_cost_label = $Camera2D/DownCostLabel
@onready var left_cost_label = $Camera2D/LeftCostLabel
@onready var right_cost_label = $Camera2D/RightCostLabel
# Velocidad del jugador
@export var speed := 200.0

var total_cost = 0.0

var idle = 0 # La use para saber en que direccion poner la idle animation
var ejeX = 0
var ejeY = 0

# Aqui guarda el camino que seguira en el A*
var path = []
var current_target_index = 0

func _ready():
	total_cost = 0.0
	update_cost_display()

func _process(delta):
	## Lo que necesita para moverse solo hacia el objetivo owo
	if path.size() > 0 and current_target_index < path.size():
		var target = world.tilemap.map_to_local(path[current_target_index])
		var direction = (target - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		animar(direction)		
		if global_position.distance_to(target) < 5:			
			var tile_position = world.tilemap.local_to_map(target)
			var current_tile = world.tilemap.get_cell_source_id(tile_position)			
			if current_tile in world.tile_cost:
				total_cost += world.tile_cost[current_tile]
			update_cost_display()			
			update_surrounding_tile_costs(tile_position)
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

func update_cost_display():
	cost_label.text = "Costo acumulado: %.2f" % total_cost

func update_surrounding_tile_costs(current_tile_position):
	# Definir las posiciones de las tiles adyacentes
	var up_tile_pos = current_tile_position + Vector2i(0, -1)
	var down_tile_pos = current_tile_position + Vector2i(0, 1)
	var left_tile_pos = current_tile_position + Vector2i(-1, 0)
	var right_tile_pos = current_tile_position + Vector2i(1, 0)

	# Obtener los IDs de las tiles adyacentes
	var up_tile = world.tilemap.get_cell_source_id(up_tile_pos)
	var down_tile = world.tilemap.get_cell_source_id(down_tile_pos)
	var left_tile = world.tilemap.get_cell_source_id(left_tile_pos)
	var right_tile = world.tilemap.get_cell_source_id(right_tile_pos)

	# Actualizar las etiquetas con los costos de las tiles adyacentes
	up_cost_label.text = "Costo Arriba: %.2f" % (world.tile_cost.get(up_tile, 0))
	down_cost_label.text = "Costo Abajo: %.2f" % (world.tile_cost.get(down_tile, 0))
	left_cost_label.text = "Costo Izquierda: %.2f" % (world.tile_cost.get(left_tile, 0))
	right_cost_label.text = "Costo Derecha: %.2f" % (world.tile_cost.get(right_tile, 0))
