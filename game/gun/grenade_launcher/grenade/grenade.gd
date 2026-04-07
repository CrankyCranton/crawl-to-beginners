class_name Grenade extends RigidBody2D


@export var speed: float = 256.0


func _ready() -> void:
	await get_tree().process_frame
	linear_velocity = global_transform.x * speed


func _on_explode_timer_timeout() -> void:
	var explosion: Explosion = preload("uid://diaumbd0fu6q4").instantiate()
	call_deferred(&"add_sibling", explosion)
	await explosion.ready
	explosion.global_position = global_position
	queue_free()
