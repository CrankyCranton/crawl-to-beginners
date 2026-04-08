class_name Hero extends CharacterBody2D


signal died

const SPEED: float = 96.0
const PANIC_SPEED: float = 192.0
const DODGE_INFLUENCE: float = 0.5
const PATH_DESIRED_DISTANCE: float = pow(8.0, 2.0)
const HEAT_SWITCH_MARGIN: float = 0.1
const DISTANCE_PREFERENCE: float = 0.001

enum State {
	NORMAL,
	PANIC,
	FOLLOW, # TODO: Follow the player outside of combat.
	POSSESSED,
}

var state: State = State.NORMAL
var safe_vel := Vector2()
var astar: AStarGrid2D
var path: PackedVector2Array = []
var target_cell := Vector2i.MAX
var room: Room
var max_health: int = 5:
	set(value):
		max_health = value
		health = health
var health: int = max_health:
	set(value):
		health = mini(max_health, value)
		if health <= 0:
			die()

@onready var nav_agent: NavigationAgent2D = $NavigationAgent
@onready var target_pos := Vector2()
@onready var panic_timer: Timer = $PanicTimer


func _ready() -> void:
	nav_agent.max_speed = SPEED / DODGE_INFLUENCE
	for i: int in 2:
		await get_tree().process_frame # Wait for the navigation to load.
	target_pos = get_random_point()


func _physics_process(_delta: float) -> void:
	match state:
		State.NORMAL:
			for y: int in range(astar.region.position.y, astar.region.end.y):
				for x: int in range(astar.region.position.x, astar.region.end.x):
					var cell := Vector2i(x, y)
					if target_cell == Vector2i.MAX or (get_cell_weight(target_cell)
							- get_cell_weight(cell)) > HEAT_SWITCH_MARGIN:
						target_cell = cell

			path = astar.get_point_path(room.get_cell_id(global_position), target_cell)
			if path.size() > 0:
				path.remove_at(0)

			if path.size() > 0:
				var local_pos: Vector2 = room.to_local(global_position)
				velocity = local_pos.direction_to(path[0]) * SPEED
				if local_pos.distance_squared_to(path[0]) <= PATH_DESIRED_DISTANCE:
					path.remove_at(0)
			else:
				velocity = Vector2.ZERO
			velocity += safe_vel

		State.PANIC:
			nav_agent.target_position = target_pos
			var path_vel: Vector2 = global_position.direction_to(
					nav_agent.get_next_path_position()) * PANIC_SPEED
			velocity = path_vel + safe_vel

		State.FOLLOW:
			pass
		State.POSSESSED:
			pass

	#velocity = velocity.limit_length(SPEED)
	move_and_slide()
	#queue_redraw()


#func _draw() -> void:
	#for i in path.size() - 1:
		#draw_line(to_local(path[i]), to_local(path[i + 1]), Color.GREEN, 4.0)


func get_cell_weight(cell: Vector2i) -> float:
	var dist: float = 0.0
	var test_path: PackedVector2Array = astar.get_point_path(
			room.get_cell_id(global_position), cell)
	for i: int in range(1, test_path.size()):
		dist += test_path[i - 1].distance_to(test_path[i])

	return astar.get_point_weight_scale(cell) * (1.0 + dist * DISTANCE_PREFERENCE)


func die() -> void:
	died.emit()
	#queue_free()


func get_random_point() -> Vector2:
	return NavigationServer2D.map_get_random_point(get_map_rid(),
			nav_agent.navigation_layers, false)


func get_map_rid() -> RID:
	return NavigationServer2D.agent_get_map(nav_agent.get_rid())


func _on_hit_box_damage_taken(damage: int) -> void:
	health -= damage
	if damage > 0:
		state = State.PANIC
		path = []
		target_cell = Vector2i.MAX
		panic_timer.start()
	elif state == State.PANIC:
		panic_timer.stop()
		state = State.NORMAL


func _on_navigation_agent_velocity_computed(safe_velocity: Vector2) -> void:
	safe_vel = safe_velocity


func _on_navigation_agent_target_reached() -> void:
	target_pos = get_random_point()


func _on_panic_timer_timeout() -> void:
	state = State.NORMAL
