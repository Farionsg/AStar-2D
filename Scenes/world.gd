extends Node2D

# Tamaño de la cuadrícula y cuartos
const MAP_WIDTH = 50
const MAP_HEIGHT = 50
const ROOM_MIN_SIZE = 8
const ROOM_MAX_SIZE = 12

# Referencia al TileMap
@onready var tilemap = $TileMap  # Asume que tienes un nodo TileMap en tu escena

var SillaScene = load("res://Scenes/silla.tscn")
var PupitreScene = load("res://Scenes/pupitre.tscn")

# IDs de tiles en el TileSet
const TILE_FLOOR = 2
const TILE_WALL = 2

var rooms = []
var corridors = []

func _ready():
	generate_map()

func generate_map():
	for i in range(20):  # Generar 10 cuartos como ejemplo
		var room = generate_random_room()
		if can_place_room(room):
			rooms.append(room)
			place_room(room)
			place_random_objects(room)
	
	connect_rooms()

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
			
			# Colocar piso
			tilemap.set_cell(Vector2i(tile_x, tile_y), TILE_FLOOR, Vector2i(2,0))
	
	# Colocar paredes alrededor del cuarto
	for x in range(room.size.x + 2):
		tilemap.set_cell(Vector2i(room.position.x + x - 1, room.position.y - 1), TILE_WALL, Vector2i(0,3))
		tilemap.set_cell(Vector2i(room.position.x + x - 1, room.position.y + room.size.y), TILE_WALL, Vector2i(0,3))
		
	for y in range(room.size.y + 2):
		tilemap.set_cell(Vector2i(room.position.x - 1, room.position.y + y - 1), TILE_WALL, Vector2i(0,3))
		tilemap.set_cell(Vector2i(room.position.x + room.size.x, room.position.y + y - 1), TILE_WALL, Vector2i(0,3))

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
	var num_objects = randi_range(1, 5)  # Número aleatorio de objetos entre 1 y 5
	
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
