class_name Hero extends CharacterBody2D


signal died
signal health_set(health: int)

const SPEED: float = 96.0
const PANIC_SPEED: float = 192.0
const DODGE_INFLUENCE: float = 0.5
const PATH_DESIRED_DISTANCE: float = pow(8.0, 2.0)
const HEAT_SWITCH_MARGIN: float = 0.1
const DISTANCE_PREFERENCE: float = 0.001
const PANIC_DISTANCE_PREF: float = 0.0

enum State {
	NORMAL,
	PANIC,
	FOLLOW, # TODO: Follow the player outside of combat.
	POSSESSED,
}

@export var ghost: Ghost

var state: State = State.NORMAL
var safe_vel := Vector2()
var astar: AStarGrid2D
var path: PackedVector2Array = []
var target_cell := Vector2i.MAX
var room: Room
var max_health: int = 8:
	set(value):
		max_health = value
		health = health
var health: int = max_health:
	set(value):
		if value < health:
			Utils.hit_flash(sprite)
		health = mini(max_health, value)
		health_set.emit(health)
		if health <= 0:
			die()
var speed: float:
	get:
		return PANIC_SPEED if state == State.PANIC else SPEED

@onready var nav_agent: NavigationAgent2D = $NavigationAgent
@onready var target_pos := Vector2()
@onready var panic_timer: Timer = $PanicTimer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get(&"parameters/playback")
@onready var sprite: Sprite2D = $Sprite
@onready var anim_dir := Vector2.DOWN:
	set(value):
		anim_dir = value
		animation_tree.set(&"parameters/idle/blend_position", anim_dir)
		animation_tree.set(&"parameters/walk/blend_position", anim_dir)


func _ready() -> void:
	nav_agent.max_speed = SPEED / DODGE_INFLUENCE
	#for i: int in 3:
		#await get_tree().process_frame # Wait for the navigation to load.
	#target_pos = get_random_point()


func _physics_process(_delta: float) -> void:
	match state:
		State.NORMAL:#, State.PANIC:
			for y: int in range(astar.region.position.y, astar.region.end.y):
				for x: int in range(astar.region.position.x, astar.region.end.x):
					var cell := Vector2i(x, y)
					var heat_switch_margin: float = (0.0 if state == State.PANIC
							else HEAT_SWITCH_MARGIN)
					if target_cell == Vector2i.MAX or (get_cell_weight(target_cell)
							- get_cell_weight(cell)) > heat_switch_margin or (state == State.PANIC and room.get_cell_id(global_position) == target_cell):
						target_cell = cell

			path = astar.get_point_path(room.get_cell_id(global_position), target_cell)
			if path.size() > 0:
				path.remove_at(0)

			if path.size() > 0:
				var local_pos: Vector2 = room.to_local(global_position)
				velocity = local_pos.direction_to(path[0]) * speed
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
			if global_position.distance_to(ghost.global_position) > 64.0:
				nav_agent.target_position = ghost.global_position
				var path_vel: Vector2 = global_position.direction_to(
						nav_agent.get_next_path_position()) * SPEED
				velocity = path_vel + safe_vel
			else:
				velocity = safe_vel

	if state != State.POSSESSED:
		#velocity = velocity.limit_length(SPEED)
		move_and_slide()


	#queue_redraw()
	animate()


#func _draw() -> void:
	#for i in path.size() - 1:
		#draw_line(to_local(path[i]), to_local(path[i + 1]), Color.GREEN, 4.0)


# Copied from enemy.gd. I should probably merge 'em somehow.
func animate() -> void:
	var anim_state: StringName = &"walk" if velocity != Vector2.ZERO else &"idle"
	if anim_state != playback.get_current_node():
		playback.travel(anim_state)
	if anim_state == &"walk":
		anim_dir = velocity.normalized()


func get_cell_weight(cell: Vector2i) -> float:
	var dist: float = 0.0
	var test_path: PackedVector2Array = astar.get_point_path(
			room.get_cell_id(global_position), cell)
	for i: int in range(1, test_path.size()):
		dist += test_path[i - 1].distance_to(test_path[i])

	var distance_preference: float = (PANIC_DISTANCE_PREF if state == State.PANIC
			else DISTANCE_PREFERENCE)
	return astar.get_point_weight_scale(cell) * (1.0 + dist * distance_preference)


func die() -> void:
	hide()
	var death_effect: AnimatedSprite2D = preload("uid://dwxvg56mqxrq3").instantiate()
	get_tree().current_scene.add_child(death_effect)
	death_effect.global_position = global_position
	died.emit()
	#queue_free()


func get_random_point() -> Vector2:
	return NavigationServer2D.map_get_random_point(get_map_rid(),
			nav_agent.navigation_layers, false)


func get_map_rid() -> RID:
	return NavigationServer2D.agent_get_map(nav_agent.get_rid())


func _on_hit_box_damage_taken(damage: int) -> void:
	health -= damage
	if damage > 0 and state != State.POSSESSED:
		state = State.PANIC
		target_pos = get_random_point()
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
	if state == State.PANIC:
		state = State.NORMAL
