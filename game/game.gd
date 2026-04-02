class_name Game extends Node


var current_room: Room = null
# The key is the room coords on the grid of rooms.
# The value is the dictionary that stores generation data to reload the room.
var room_data: Dictionary[Vector2i, Dictionary] = {}

@onready var ghost: Ghost = $Ghost
@onready var hero: Hero = $Hero


func _ready() -> void:
	create_room(Vector2i.ZERO)


func create_room(coords: Vector2i) -> void:
	assert(not room_data.keys().has(coords), "A room at " + str(coords) + " already exists.")

	if current_room != null:
		current_room.queue_free()

	const ROOM: PackedScene = preload("uid://dve2qpah2d01m")
	var room: Room = ROOM.instantiate()
	room.coords = coords
	current_room = room
	# TODO: Add doors randomly taking into account the surrounding rooms.
	room_data[coords] = room.get_random_data()
	add_child(room)
	room.hero = hero
	room.generate(room_data[coords])

	ghost.bounds = room.get_bounding_rect()
	# TODO: Set player/ghost positions.
