extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var world = get_parent()
# Velocidad del jugador
@export var speed := 200.0
var idle = 0
var satanas = Vector2.ZERO

var path = []
var current_target_index = 0

func _process(delta):
	
	if path.size() > 0 and current_target_index < path.size():
		var target = world.tilemap.map_to_local(path[current_target_index])
		var direction = (target - global_position).normalized()
		
		velocity = direction * speed
		move_and_slide()
		satanas += global_position
		
		
		if global_position.distance_to(target) < 5:
			current_target_index += 1
	else:
		velocity = Vector2.ZERO
		move_and_slide()
	
	
	## Movimiento del jugador con input de teclado
	#var direction = Vector2.ZERO
	#if Input.is_action_pressed("Right"):
		#direction.x += 1
	#if Input.is_action_pressed("Left"):
		#direction.x -= 1
	#if Input.is_action_pressed("Down"):
		#direction.y += 1
	#if Input.is_action_pressed("Up"):
		#direction.y -= 1
#
	## Mover al jugador en la dirección indicada con una velocidad constante
	#velocity = direction.normalized() * speed
	#move_and_slide()
	#
	#if direction.x != 0 or direction.y != 0:
		#animated_sprite.play()
		#if direction.x > 0:
			#animated_sprite.animation = "WalkR"
			#idle = 0
		#elif direction.x < 0:
			#animated_sprite.animation = "WalkL"
			#idle = 1
		#elif direction.y > 0:
			#animated_sprite.animation = "WalkD"
			#idle = 2
		#elif direction.y < 0:
			#animated_sprite.animation = "WalkU"
			#idle = 3
	#else:
		#match idle:
			#0:
				#animated_sprite.animation = "idleRight"
			#1:
				#animated_sprite.animation = "idleLeft"
			#2:
				#animated_sprite.animation = "idleDown"
			#3:
				#animated_sprite.animation = "idleUp"
				
func move_to_book():
	# Obtener posición actual del jugador
	var start = world.tilemap.local_to_map(global_position)
	var end = world.libro_position

	# Generar el camino usando AStar
	path = world.astar.get_point_path(start.x + start.y * world.MAP_WIDTH, end.x + end.y * world.MAP_WIDTH)
	current_target_index = 0
