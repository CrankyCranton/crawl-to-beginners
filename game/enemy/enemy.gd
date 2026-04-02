class_name Enemy extends CharacterBody2D


const SPEED: float = 64.0

var hero: Hero

@onready var soft_collision: SoftCollision = $SoftCollision


func _physics_process(_delta: float) -> void:
	if hero == null:
		return

	var straight_direction: Vector2 = global_position.direction_to(hero.global_position)
	velocity = (straight_direction + soft_collision.get_vector()).normalized() * SPEED
	move_and_slide()
