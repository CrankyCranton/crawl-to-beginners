class_name Game extends Node


const MAP_BOUNDS := Rect2i(Vector2i(-1, -5), Vector2i(3, 5))
const ROOM_TYPES: Array[PackedScene] = [
	preload("uid://dve2qpah2d01m"), # Temp
]

var current_room: Room = null
# The key is the room coords on the grid of rooms.
# The value is the dictionary that stores generation data to reload the room.
# a room's data: { "type": <PackedScene>, "mod": <Room.Mod>, "unknown": <bool> }
var room_data: Dictionary[Vector2i, Dictionary] = {
	Vector2i(0, -1): {
		"type": preload("uid://dqy3xw22pfpyi"),
		"mod": Room.Mod.NM,
		"unknown": false,
	},
	Vector2i(0, -5): {
		"type": preload("uid://3fx73qj3644i"),
		"mod": Room.Mod.NM,
		"unknown": false,
	},
}

@onready var ghost: Ghost = $Ghost
@onready var hero: Hero = $Hero
@onready var minimap: Minimap = %Minimap


func _ready() -> void:
	generate_data()
	var sorted_coords: Array = room_data.keys()
	sorted_coords.sort_custom(sort_coords)
	for coords: Vector2i in sorted_coords:
		var data: Dictionary = room_data[coords]
		minimap.add_room(coords, data.mod, data.unknown)

	enter_room(Vector2(0, -1))


func sort_coords(a: Vector2i, b: Vector2i) -> bool:
	if a.y == b.y:
		return a.x <= b.x
	else:
		return a.y <= b.y


func generate_data() -> void:
	for y: int in range(MAP_BOUNDS.position.y, MAP_BOUNDS.end.y):
		for x: int in range(MAP_BOUNDS.position.x, MAP_BOUNDS.end.x):
			var coords := Vector2i(x, y)
			if room_data.has(coords):
				continue

			var mod := (randi() % Room.Mod.size()) as Room.Mod
			var unknown: bool = randf() < 1.0 / ROOM_TYPES.size() and mod != Room.Mod.NM
			room_data[coords] = {
				"type": ROOM_TYPES.pick_random(),
				"mod": mod,
				"unknown": unknown,
			}


func enter_room(coords: Vector2i) -> void:
	assert(room_data.has(coords))
	var enter_direction := Vector2i()
	if current_room != null:
		# NOTE:
		# If the player is possessing an enemy,
		# don't forget to reparent the enemy to the next room.
		enter_direction = coords - current_room.coords
		current_room.queue_free()

	minimap.set_unknown(coords, false)
	var room: Room = room_data[coords].type.instantiate()
	room.coords = coords
	current_room = room
	room.door_entered.connect(_on_room_door_entered)

	ghost.process_mode = Node.PROCESS_MODE_DISABLED
	hero.process_mode = Node.PROCESS_MODE_DISABLED
	call_deferred(&"add_child", room)
	await room.ready

	room.hero = hero
	hero.room = room

	for dir: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		if not MAP_BOUNDS.has_point(coords + dir):
			room.disable_door(dir)
	room.set_mod(room_data[coords].mod)

	await get_tree().create_timer(0.0).timeout
	if enter_direction != Vector2i.ZERO:
		var spawn_point: Vector2 = room.get_door(-enter_direction).spawn_point.global_position
		#const RAND_OFFSET: float = 8.0
		hero.global_position = spawn_point# + Utils.rand_vec2_radial(RAND_OFFSET)
		ghost.global_position = spawn_point# + Utils.rand_vec2_radial(RAND_OFFSET)


	ghost.process_mode = Node.PROCESS_MODE_INHERIT
	hero.process_mode = Node.PROCESS_MODE_INHERIT


func _on_room_door_entered(direction: Vector2i) -> void:
	enter_room(current_room.coords + direction)
