class_name Steering extends Node2D


@export var enabled := true:
	set(value):
		enabled = value
		for ray: RayCast2D in get_children():
			ray.enabled = enabled
@export var rays: int = 32
@export var radius: float = 512.0
@export_flags_2d_physics var collision_mask: int = 1


func _ready() -> void:
	for i: int in rays:
		var ray := RayCast2D.new()
		ray.collision_mask = collision_mask
		ray.target_position = Vector2(radius, 0.0)
		ray.rotation = TAU * i / rays
		ray.enabled = enabled
		ray.collide_with_areas = true
		add_child(ray)


func get_directions() -> PackedVector2Array:
	var result: PackedVector2Array = []
	for ray: RayCast2D in get_children():
		# Probably not the cleanest method, but it'll work for now.
		var dir: Vector2 = (to_local(ray.get_collision_point())
				if ray.is_colliding() else ray.target_position.rotated(ray.rotation))
		result.append(dir / radius)
	return result
