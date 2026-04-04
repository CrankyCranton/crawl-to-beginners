class_name Gun extends Marker2D


@export var magazine: Magazine
@export_flags_2d_physics var collision_mask: int = 513

var cooling := false
var reloading := false

@onready var cooldown: Timer = $Cooldown
@onready var reload_time: Timer = $ReloadTime
@onready var barrel: Marker2D = $Barrel


func shoot() -> void:
	if magazine.ammo == 0 or cooling or reloading:
		return

	magazine.ammo -= 1
	var bullet: Node2D = magazine.ammo_type.instantiate()
	get_room().add_child(bullet)
	if bullet is CollisionObject2D:
		bullet.collision_mask = collision_mask
	bullet.global_transform = barrel.global_transform
	cooling = true
	cooldown.start()


func reload(from_mag: Magazine) -> void:
	if reloading:
		return
	reloading = true
	magazine.reload(from_mag)
	reload_time.start()


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
