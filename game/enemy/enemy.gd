class_name Enemy extends CharacterBody2D


signal died
signal removed

enum State {
	NORMAL,
	POSSESSED,
}

const SOFT_COLLISION_INFLUENCE: float = 0.5
# Squared to save on performance when compairing distances to it.
const PATH_DESIRED_DISTANCE: float = pow(8.0, 2.0)

@export var speed: float = 72.0
@export var aim_speed: float = 15.0
@export var aim_margin: float = 1.0
@export var gun: Node2D
@export var health: int = 3:
	set(value):
		health = value
		if health <= 0:
			die()

var dead := false
var hero: Hero
var last_hero_pos := Vector2i.MAX
var astar: AStarGrid2D
var path: PackedVector2Array = []
var room: Room
var state: State = State.NORMAL:
	set(value):
		state = value
		if state == State.POSSESSED:
			removed.emit()

@onready var soft_collision: SoftCollision = $SoftCollision
@onready var hand: Marker2D = $Hand
@onready var los: ShapeCast2D = %LOS
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent
@onready var hit_box: HitBox = $HitBox
@onready var collision_shape: CollisionShape2D = $CollisionShape


func _ready() -> void:
	hand.rotation = randf() * TAU
	aim_margin = deg_to_rad(aim_margin)
	los.add_exception(self)
	gun.mag_empty.connect(_on_gun_mag_empty)


func _physics_process(delta: float) -> void:
	match state:
		State.NORMAL:
			if hero == null:
				return

			if gun.global_position.distance_to(hero.global_position) <= gun.range:
				var target_angle: float = hand.global_position.angle_to_point(hero.global_position)
				hand.global_rotation = lerp_angle(hand.global_rotation,
						target_angle, aim_speed * delta)
				los.target_position = los.to_local(hero.global_position)
				var aim_accuracy: float = absf(hand.global_transform.x.angle_to(
						hand.global_position.direction_to(hero.global_position)))


				if not los.is_colliding():
					if aim_accuracy <= aim_margin:
						gun.shoot()
			#else:
			var hero_cell_pos: Vector2i = room.get_cell_id(hero.global_position)
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
				velocity = (straight_direction + soft_vector).normalized() * speed
				move_and_slide()

				if position.distance_squared_to(path[0]) <= PATH_DESIRED_DISTANCE:
					path.remove_at(0)

			#queue_redraw()


#func _draw() -> void:
	#for i in path.size() - 1:
		#draw_line(to_local(path[i]), to_local(path[i + 1]), Color.RED, 1.0)


func die() -> void:
	dead = true
	collision_shape.set_deferred(&"disabled", true)
	#remove_from_group(&"enemies")
	removed.emit()
	died.emit()
	queue_free()


func drop_gun() -> void:
	gun.queue_free()
	var fists: Fists = preload("uid://cap0tc1j8ohhe").instantiate()
	fists.collision_mask = gun.collision_mask
	hand.add_child(fists)
	gun = fists


func _on_hit_box_damage_taken(damage: int) -> void:
	health -= damage


func _on_gun_mag_empty() -> void:
	drop_gun()
