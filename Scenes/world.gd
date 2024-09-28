extends Node2D

# Estas variables se usaran para modificar el mundo a nuestro gusto
const MAP_WIDTH = 50		# De que size queremos el mundo
const MAP_HEIGHT = 50
const ROOM_MIN_SIZE = 8     # Como queremos los cuartos dentro del mundo
const ROOM_MAX_SIZE = 12    # Cuartos mas chiquitos implican mas cuartos

@onready var tilemap = $TileMap
@onready var player = $CharacterBody2D
var astar: AStar2D = AStar2D.new()
var SillaScene = load("res://Scenes/silla.tscn")
var PupitreScene = load("res://Scenes/pupitre.tscn")
var LibroScene = load("res://Scenes/libro.tscn")

# Estas son el indice de la textura que queremos usar para el tilemap
var TILE_FLOOR = 2
const TILE_WATER = 4
const TILE_GRASS = 5
const TILE_MUD = 6
const TILE_WALL = 3

var tile_atlas_cords = Vector2.ZERO

var tile_cost = {
	TILE_FLOOR : 1.0,
	TILE_MUD   : 2.0,
	TILE_GRASS : 3.0,
	TILE_WATER : 4.0
	}

# Guarda el mapa en arreglos
var rooms = []
var corridors = []
var libro_position = Vector2i.ZERO
var pausa = false

func _ready():
	get_tree().paused = false
	generate_map()
	generate_astar_graph()
	spawn_book_in_random_room()
	player.move_to_book()

func _process(delta):
		if Input.is_action_just_pressed("escape"):
			if !pausa:
				$CharacterBody2D/Esc/VBoxContainer/Button.show()
				$CharacterBody2D/Esc/VBoxContainer/Button2.show()
				$CharacterBody2D/Esc/VBoxContainer/Button3.show()
				pausa = true
				get_tree().paused = true				

func generate_map():
	# Generar cuartos y pasillos
	for i in range(20):  
		var room = generate_random_room()
		if can_place_room(room):
			rooms.append(room)
			place_room(room)
			place_random_objects(room)
	connect_rooms()
	
	# Spawn del jugador en un cuarto aleatorio
	var random_room = get_random_room()
	if random_room:
		player.global_position = tilemap.map_to_local(Vector2(random_room.position.x + 1, random_room.position.y + 1))

func spawn_book_in_random_room():
	var random_room = get_random_room()
	if random_room:
		var libro_instance = LibroScene.instantiate()
		var book_x = randi_range(random_room.position.x, random_room.position.x + random_room.size.x - 1)
		var book_y = randi_range(random_room.position.y, random_room.position.y + random_room.size.y - 1)
		libro_position = Vector2(book_x, book_y)
		libro_instance.position = tilemap.map_to_local(Vector2(book_x, book_y))
		add_child(libro_instance)

# AStar configuration, solo movimientos cardinales osea sin diagonales
func generate_astar_graph():
	## -----------------------¿COMO FUNCIONA EL ASTAR?---------------------------
	astar.clear() # Primero limpiamos cualquier cosa que pueda molestar
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT): # Le damos el rango del mapa que va a buscar
			var tile_type = tilemap.get_cell_source_id(Vector2(x, y)) # Esto es para saber que tile es piso
			if tile_type in tile_cost:								  # Y CUAL ES PARED
				var id = x + y * MAP_WIDTH   		 # Como si es piso entonces entra y
				var position = Vector2(x, y)
				var weight_scale = tile_cost[tile_type]
				astar.add_point(id, position, weight_scale)	 # Se crea una id de la tile para agregarla al path			
				# Conectar solo con los puntos vecinos en las direcciones cardinales
				for dir in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]: # Esto de vector es para no dar diagonales
					var neighbor_x = x + dir.x	# Define las direcciones de los vecinos arriba y al lado
					var neighbor_y = y + dir.y  # Para saber si son piso y poder agregarlo al mapa
					if neighbor_x >= 0 and neighbor_x < MAP_WIDTH and neighbor_y >= 0 and neighbor_y < MAP_HEIGHT: # QUE NO SE SALGA DEL MAPA
						var neighbor_tile = tilemap.get_cell_source_id(Vector2(neighbor_x, neighbor_y)) # Hace lo mismo de saber si es piso o pared
						if neighbor_tile in tile_cost:
							var neighbor_id = neighbor_x + neighbor_y * MAP_WIDTH
							astar.connect_points(id, neighbor_id)  # Si es piso lo conecta mucho gusto
	## ------AHORA TENEMOS TODO EL MAPA EN NODOS -> player.gd move_to_book() PARA SABER COMO HACE EL PATH-----------------

# Devuelve un cuarto aleatorio
func get_random_room():
	if rooms.size() > 0:
		return rooms[randi() % rooms.size()]
	return null

func generate_random_room():
	var room_size_x = randi_range(ROOM_MIN_SIZE, ROOM_MAX_SIZE)
	var room_size_y = randi_range(ROOM_MIN_SIZE, ROOM_MAX_SIZE)
	var room_pos_x = randi_range(0, MAP_WIDTH - room_size_x)
	var room_pos_y = randi_range(0, MAP_HEIGHT - room_size_y)
	
	return Rect2(room_pos_x, room_pos_y, room_size_x, room_size_y)

func can_place_room(room):
	for existing_room in rooms:
		if room.intersects(existing_room):
			return false
	return true

func place_room(room):
	# Coloca pisos y paredes usando el TileMap
	for x in range(room.size.x):
		for y in range(room.size.y):
			var tile_x = room.position.x + x
			var tile_y = room.position.y + y
			
			var floor_tiles = [TILE_FLOOR, TILE_MUD, TILE_GRASS, TILE_WATER]
			var probabilities = [0.5, 0.3, 0.10, 0.10]
			var tile_type = choose_random_tile(floor_tiles, probabilities)
			# Colocar piso
			tilemap.set_cell(Vector2i(tile_x, tile_y), tile_type, tile_atlas_cords)
	
	# Colocar paredes alrededor del cuarto
	for x in range(room.size.x + 2):
		tilemap.set_cell(Vector2i(room.position.x + x - 1, room.position.y - 1), TILE_WALL, Vector2i(0,3))
		tilemap.set_cell(Vector2i(room.position.x + x - 1, room.position.y + room.size.y), TILE_WALL, Vector2i(0,3))
		
	for y in range(room.size.y + 2):
		tilemap.set_cell(Vector2i(room.position.x - 1, room.position.y + y - 1), TILE_WALL, Vector2i(0,3))
		tilemap.set_cell(Vector2i(room.position.x + room.size.x, room.position.y + y - 1), TILE_WALL, Vector2i(0,3))

func choose_random_tile(tiles, probabilities):
	var rand = randf()
	var cumulative = 0.0
	for i in range(tiles.size()):
		cumulative += probabilities[i]
		if rand < cumulative:
			match i:
				1:
					tile_atlas_cords = Vector2i(2,0)
				2:
					tile_atlas_cords = Vector2i(1,4)
				3:
					tile_atlas_cords = Vector2i(1,3)
				4:
					tile_atlas_cords = Vector2i(0,4)
			return tiles[i]
	tile_atlas_cords = Vector2i(2,0)
	return tiles[tiles.size() - 1]

func connect_rooms():
	# Conectar los cuartos con pasillos
	for i in range(1, rooms.size()):
		var room_a = rooms[i - 1]
		var room_b = rooms[i]
		create_corridor(room_a, room_b)

func create_corridor(room_a, room_b):
	var corridor = []
	corridor.append(room_a.position)
	corridor.append(Vector2(room_b.position.x, room_a.position.y))
	corridor.append(room_b.position)
	
	for i in range(corridor.size() - 1):
		var start = corridor[i]
		var end = corridor[i + 1]
		if start.x == end.x:
			for y in range(min(start.y, end.y), max(start.y, end.y) + 1):
				tilemap.set_cell(Vector2i(start.x, y), TILE_FLOOR, Vector2i(2,0))
		elif start.y == end.y:
			for x in range(min(start.x, end.x), max(start.x, end.x) + 1):
				tilemap.set_cell(Vector2i(x, start.y), TILE_FLOOR, Vector2i(2,0))
				
func place_random_objects(room):
	var num_objects = randi_range(1, 10)  # Número aleatorio de objetos entre 1 y 5
	
	for i in range(num_objects):
		# Seleccionar un objeto aleatorio
		var object_scene = get_random_object_scene()
		var object_instance = object_scene.instantiate()
		
		# Posicionar el objeto aleatoriamente dentro de la habitación
		var object_x = randi_range(room.position.x, room.position.x + room.size.x - 1)
		var object_y = randi_range(room.position.y, room.position.y + room.size.y - 1)
		
		# Ajusta la posición del objeto
		object_instance.position = Vector2(object_x * 48, object_y * 48)
		
		# Añadir el objeto a la escena
		add_child(object_instance)

# Función para seleccionar un objeto aleatorio
func get_random_object_scene():
	var objects = [ SillaScene, PupitreScene ]
	return objects[randi() % objects.size()]


func _on_reiniciar_pressed() -> void:
	get_tree().reload_current_scene()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_continuar_pressed() -> void:
	$CharacterBody2D/Esc/VBoxContainer/Button.hide()
	$CharacterBody2D/Esc/VBoxContainer/Button2.hide()
	$CharacterBody2D/Esc/VBoxContainer/Button3.hide()
	pausa = false
	get_tree().paused = false
