# NOTE: It isn't necessary to make this script an autoload - all the funcions are static.
class_name Utils extends Node



static func hit_flash(item: CanvasItem, duration: float = 0.2) -> void:
	const HIT_FLASH: ShaderMaterial = preload("res://game/vfx/hit_flash.material")
	var used_parent_material := item.use_parent_material
	item.use_parent_material = false
	var previous_material: Material = item.material
	item.material = HIT_FLASH

	await item.get_tree().create_timer(duration, false).timeout
	if item != null:
		item.material = previous_material
		item.use_parent_material = used_parent_material


static func vec3_to_2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


static func vec2_to_3(vec2: Vector2, y: float = 0.0) -> Vector3:
	return Vector3(vec2.x, y, vec2.y)


static func rand_vec2_radial(radius: float) -> Vector2:
	return Vector2(radius * randf(), 0.0).rotated(TAU * randf())


static func rand_vec2_range(minimum: Vector2, maximum: Vector2) -> Vector2:
	return Vector2(randf_range(minimum.x, maximum.x), randf_range(minimum.y, maximum.y))


static func rand_vec3_range(minimum: Vector3, maximum: Vector3) -> Vector3:
	return Vector3(randf_range(minimum.x, maximum.x), randf_range(minimum.y, maximum.y), randf_range(minimum.z, maximum.z))
