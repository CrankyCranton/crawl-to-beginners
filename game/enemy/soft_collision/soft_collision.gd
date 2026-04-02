class_name SoftCollision extends Area2D


@export var influence: float = 1.0

@onready var collision_shape: CollisionShape2D = $CollisionShape


func get_vector() -> Vector2:
	var result := Vector2()
	for soft_collision: SoftCollision in get_overlapping_areas():
		var vector: Vector2 = soft_collision.global_position.direction_to(global_position)
		vector *= soft_collision.influence
		result += vector
	if get_overlapping_bodies().size() > 0:
		result /= get_overlapping_areas().size()
	return result
