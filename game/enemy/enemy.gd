class_name Enemy extends CharacterBody2D


const SPEED: float = 64.0
const SOFT_COLLISION_INFLUENCE: float = 0.25

var hero: Hero

@onready var soft_collision: SoftCollision = $SoftCollision


func _physics_process(_delta: float) -> void:
	if hero == null:
		return

	var straight_direction: Vector2 = global_position.direction_to(hero.global_position)
	var soft_vector: Vector2 = soft_collision.get_vector() * SOFT_COLLISION_INFLUENCE
	velocity = (straight_direction + soft_vector).normalized() * SPEED
	move_and_slide()
