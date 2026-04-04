class_name Enemy extends CharacterBody2D


const SPEED: float = 64.0
const SOFT_COLLISION_INFLUENCE: float = 0.25
const AIM_SPEED: float = 15.0

@export var health: int = 3:
	set(value):
		health = value
		if health <= 0:
			die()
@export var aim_margin: float = 2.0

var hero: Hero

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
	else:
		navigation_agent.target_position = hero.global_position
		var straight_direction: Vector2 = global_position.direction_to(
				navigation_agent.get_next_path_position())
		var soft_vector: Vector2 = soft_collision.get_vector() * SOFT_COLLISION_INFLUENCE
		velocity = (straight_direction + soft_vector).normalized() * SPEED
		move_and_slide()


func die() -> void:
	queue_free()


func _on_hit_box_damage_taken(damage: int) -> void:
	health -= damage
