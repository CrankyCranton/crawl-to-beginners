class_name Gun extends Marker2D


signal mag_empty
signal shot(ammo: int, cooldown: float)

@export var magazine: Magazine
@export_flags_2d_physics var collision_mask: int = 513
@warning_ignore("shadowed_global_identifier")
@export var range: float = INF
@export var exceptions: Array[Node] = []
@export var flip := false

var cooling := false
var reloading := false

@onready var cooldown: Timer = $Cooldown
@onready var reload_time: Timer = $ReloadTime
@onready var barrel: Marker2D = $Barrel
@onready var sprite: Sprite2D = $Sprite2D


func _process(_delta: float) -> void:
	if flip:
		sprite.flip_v = sprite.global_transform.x.x < 0.0


func shoot() -> void:
	if magazine.ammo == 0 or cooling or reloading:
		return

	magazine.ammo -= 1
	var bullet: Node2D = magazine.ammo_type.instantiate()
	# Kinda redundant.
	if bullet is CollisionObject2D or bullet is RayCast2D or bullet is ShapeCast2D:
		bullet.collision_mask = collision_mask

	if bullet is PhysicsBody2D or bullet is RayCast2D or bullet is ShapeCast2D:
		var method: Callable = (bullet.add_collision_exception_with if bullet is PhysicsBody2D
			else bullet.add_exception)
		for exception: Node in exceptions:
			method.call(exception)
	elif bullet is Bullet:
		bullet.exceptions = exceptions


	get_room().add_child(bullet)
	bullet.global_transform = barrel.global_transform
	cooling = true
	cooldown.start()
	shot.emit(magazine.ammo, cooldown.time_left)
	if magazine.ammo == 0:
		mag_empty.emit()


func reload(from_mag: Magazine) -> void:
	if reloading:
		return
	reloading = true
	magazine.reload(from_mag)
	reload_time.start()


func set_collision_mask_value(layer_number: int, value: bool) -> void:
	# IDK how to deal with bits, so I'll just cheat a "bit".
	var temp := Area2D.new()
	temp.collision_mask = collision_mask
	temp.set_collision_mask_value(layer_number, value)
	collision_mask = temp.collision_mask


func get_collision_mask_value(layer_number: int) -> bool:
	var temp := Area2D.new()
	temp.collision_mask = collision_mask
	return temp.get_collision_mask_value(layer_number)


func get_room() -> Node:
	var result: Node = get_parent()
	while (result != get_tree().current_scene and result != get_node(^"/root")
			and not result is Room):
		result = result.get_parent()
	return result


func _on_cooldown_timeout() -> void:
	cooling = false


func _on_reload_time_timeout() -> void:
	reloading = false
