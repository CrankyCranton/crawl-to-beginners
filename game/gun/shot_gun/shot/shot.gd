class_name Shot extends ShapeCast2D
# TODO: Change to Area2D.


func _ready() -> void:
	await get_tree().physics_frame
	force_shapecast_update()
	if is_colliding():
		get_collider(0).take_damage(-1)
		print(get_collider(0).get_parent())
	#get_tree().paused = true
	#var freeze_frames: int = 10
	#for i: int in freeze_frames:
		#await get_tree().physics_frame
	#get_tree().paused = false
	queue_free()
