class_name Hero extends CharacterBody2D


const SPEED: float = 64.0
const DODGE_INFLUENCE: float = 1.0

enum State {
	NORMAL, # Navigates to random points on the map.
	AFRAID, # Normal but sped up and with randomness.
	FOLLOW, # Follow the player outside of combat.
}

var state: State = State.NORMAL
var max_health: int = 3:
	set(value):
		max_health = value
		health = health
var health: int = max_health:
	set(value):
		health = mini(max_health, value)
		if health <= 0:
			die()
var safe_vel := Vector2()

@onready var nav_agent: NavigationAgent2D = $NavigationAgent
@onready var target_pos := Vector2()


func _ready() -> void:
	nav_agent.max_speed = SPEED / DODGE_INFLUENCE
	for i: int in 2:
		await get_tree().process_frame
	target_pos = get_random_point()


func _physics_process(_delta: float) -> void:
	match state:
		State.NORMAL:
			nav_agent.target_position = target_pos
			var path_vel: Vector2 = global_position.direction_to(
					nav_agent.get_next_path_position()) * SPEED
			velocity = (path_vel + safe_vel)#.limit_length(SPEED)
		State.AFRAID:
			# NOTE: Can use a looping timer to randomly set the direction,
			# with priority towards away from the enemy.
			pass
		State.FOLLOW:
			pass

	move_and_slide()


func die() -> void:
	queue_free()


func get_random_point() -> Vector2:
	return NavigationServer2D.map_get_random_point(get_map_rid(),
			nav_agent.navigation_layers, false)


func get_map_rid() -> RID:
	return NavigationServer2D.agent_get_map(nav_agent.get_rid())


func _on_hit_box_damage_taken(damage: int) -> void:
	health -= damage


func _on_navigation_agent_velocity_computed(safe_velocity: Vector2) -> void:
	safe_vel = safe_velocity


func _on_navigation_agent_target_reached() -> void:
	if state == State.NORMAL:
		target_pos = get_random_point()
