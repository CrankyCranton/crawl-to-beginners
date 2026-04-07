class_name Enemy extends CharacterBody2D


const SPEED: float = 96.0
const SOFT_COLLISION_INFLUENCE: float = 0.5
const AIM_SPEED: float = 30.0
# Squared to save on performance when compairing distances to it.
const PATH_DESIRED_DISTANCE: float = pow(8.0, 2.0)

@export var health: int = 3:
	set(value):
		health = value
		if health <= 0:
			die()
@export var aim_margin: float = 1.0

var hero: Hero
var last_hero_pos := Vector2i.MAX
var astar: AStarGrid2D
var path: PackedVector2Array = []
var room: Room

@onready var soft_collision: SoftCollision = $SoftCollision
@onready var hand: Marker2D = $Hand
@onready var gun: Gun = $Hand/Gun # Temp
@onready var los: ShapeCast2D = %LOS
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent


func _ready() -> void:
	hand.rotation = randf() * TAU
	aim_margin = deg_to_rad(aim_margin)
	los.add_exception(self)


func _physics_process(delta: float) -> void:
	if hero == null:
		return

	var target_angle: float = hand.global_position.angle_to_point(hero.global_position)
	hand.global_rotation = lerp_angle(hand.global_rotation, target_angle, AIM_SPEED * delta)
	los.target_position = los.to_local(hero.global_position)
	var aim_accuracy: float = absf(hand.global_transform.x.angle_to(
			hand.global_position.direction_to(hero.global_position)))

	if not los.is_colliding():
		if aim_accuracy <= aim_margin:
			gun.shoot()
	#else:
	var hero_cell_pos := room.get_cell_id(hero.global_position)
	if last_hero_pos != hero_cell_pos:
		last_hero_pos = hero_cell_pos
		path = astar.get_point_path(room.get_cell_id(global_position), hero_cell_pos)
		if path.size() > 0:
			path.remove_at(0)

	if path.size() > 0:
		#navigation_agent.target_position = hero.global_position
		#var straight_direction: Vector2 = global_position.direction_to(
				#navigation_agent.get_next_path_position())
		var straight_direction: Vector2 = position.direction_to(path[0])

		var soft_vector: Vector2 = soft_collision.get_vector() * SOFT_COLLISION_INFLUENCE
		velocity = (straight_direction + soft_vector).normalized() * SPEED
		move_and_slide()

		if position.distance_squared_to(path[0]) <= PATH_DESIRED_DISTANCE:
			path.remove_at(0)

	queue_redraw()


#func _draw() -> void:
	#for i in path.size() - 1:
		#draw_line(to_local(path[i]), to_local(path[i + 1]), Color.RED, 1.0)


func die() -> void:
	queue_free()


func _on_hit_box_damage_taken(damage: int) -> void:
	health -= damage
