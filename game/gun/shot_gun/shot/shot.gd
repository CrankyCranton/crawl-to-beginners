extends RayCast2D

func _ready() -> void:
	await get_tree().physics_frame
	force_raycast_update()
	if is_colliding():
		get_collider().take_damage(-1)
	queue_free()
