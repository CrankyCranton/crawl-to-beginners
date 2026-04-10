class_name Shot extends ShapeCast2D
# TODO: Change to Area2D.


func _ready() -> void:
	await get_tree().physics_frame
	force_shapecast_update()
	if is_colliding():
		get_collider(0).take_damage(-1)
	queue_free()
