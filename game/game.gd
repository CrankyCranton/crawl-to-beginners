class_name Game extends Node


const MAP_BOUNDS := Rect2i(Vector2i(0, -5), Vector2i(1, 5))
const ROOM_TYPES: Array[PackedScene] = [
	preload("uid://b7382teb2u2p"),
	preload("uid://famvsevwf6s8"),

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
	Vector2i(0, -2): {
		"type": preload("uid://dqy3xw22pfpyi"),
		"mod": Room.Mod.NM,
		"unknown": false,
	},
	Vector2i(0, -3): {
		"type": preload("uid://dqy3xw22pfpyi"),
		"mod": Room.Mod.NM,
		"unknown": false,
	},
	Vector2i(0, -4): {
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
@onready var hud: CanvasLayer = $HUD
@onready var fps: Label = %FPS
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_bar_tween: ProgressBar = %HealthBarTween
@onready var health_bar_hud: HBoxContainer = %HealthBarHUD
@onready var ammo_hud: HBoxContainer = %AmmoHUD
@onready var reload_bar: ProgressBar = %ReloadBar
@onready var ammo_counter: Label = %AmmoCounter


func _ready() -> void:
	Engine.time_scale = 1.0
	health_bar.max_value = hero.max_health
	health_bar.value = hero.health
	generate_data()
	var sorted_coords: Array = room_data.keys()
	sorted_coords.sort_custom(sort_coords)
	for coords: Vector2i in sorted_coords:
		var data: Dictionary = room_data[coords]
		minimap.add_room(coords, data.mod, data.unknown)

	enter_room(Vector2(0, -1))


func _process(_delta: float) -> void:
	fps.text = str(Performance.get_monitor(Performance.TIME_FPS))


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
			var unknown: bool = randf() < 1.0 / Room.Mod.size() and mod != Room.Mod.NM
			room_data[coords] = {
				"type": ROOM_TYPES.pick_random(),
				"mod": mod,
				"unknown": unknown,
			}


func enter_room(coords: Vector2i) -> void:
	assert(room_data.has(coords))

	Engine.time_scale = 0.8
	var enter_direction := Vector2i()
	if current_room != null:
		# NOTE:
		# If the player is possessing an enemy,
		# don't forget to reparent the enemy to the next room.
		enter_direction = coords - current_room.coords
		current_room.queue_free()
		#Engine.time_scale += 0.2

	# FIXME: Needs to reveal the adjacent rooms as well, and show the room you're currently in.
	minimap.set_unknown(coords, false)

	var room: Room = room_data[coords].type.instantiate()
	room.coords = coords
	current_room = room
	room.door_entered.connect(_on_room_door_entered)
	room.unlocked.connect(_on_room_unlocked)

	ghost.process_mode = Node.PROCESS_MODE_DISABLED
	hero.process_mode = Node.PROCESS_MODE_DISABLED
	call_deferred(&"add_child", room)
	await room.ready

	room.hero = hero
	hero.room = room
	ghost.room = room

	for dir: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		if not MAP_BOUNDS.has_point(coords + dir):
			room.disable_door(dir)
	#room.set_mod(room_data[coords].mod)

	await get_tree().create_timer(0.0).timeout
	if enter_direction != Vector2i.ZERO:
		var spawn_point: Vector2 = (room.spawn_point if room.spawn_point != null
				else room.get_door(-enter_direction).spawn_point).global_position
		const RAND_OFFSET: float = 8.0
		hero.global_position = spawn_point + Utils.rand_vec2_radial(RAND_OFFSET)
		ghost.global_position = spawn_point + Utils.rand_vec2_radial(RAND_OFFSET)
		if ghost.possessing:
			ghost.possessing.global_position = ghost.global_position
			ghost.possessing.room = room


	hero.process_mode = Node.PROCESS_MODE_INHERIT
	ghost.process_mode = Node.PROCESS_MODE_INHERIT
	ghost.can_possess = true


func _on_room_door_entered(direction: Vector2i) -> void:
	enter_room(current_room.coords + direction)


func _on_room_unlocked() -> void:
	ghost.can_possess = false
	if current_room.scene_file_path == "res://game/room/boss_room.tscn":
		pass # Win.


func _on_hero_died() -> void:
	# IDK about these UIDs, they're hard to read.
	hud.add_child(preload("uid://beiuvxh8fcqp4").instantiate())


func _on_hero_health_set(health: int) -> void:
	health_bar.value = health
	var tween_value: float = remap(health_bar.value, health_bar.min_value, health_bar.max_value,
			health_bar_tween.min_value, health_bar_tween.max_value)
	var tween: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS
			).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC).set_parallel()
	tween.tween_property(health_bar_tween, ^"value", tween_value, 0.75)
	health_bar_hud.modulate = Color.WHITE * 2.0
	tween.tween_property(health_bar_hud, ^"modulate", Color.WHITE, 0.75)


func _on_ghost_shot(ammo: int, cooldown: float) -> void:
	ammo_hud.visible = ammo != 0
	ammo_counter.visible = ammo > 0
	ammo_counter.text = str(ammo)
	reload_bar.value = 1.0
	create_tween().tween_property(reload_bar, ^"value", 0.0, cooldown)
