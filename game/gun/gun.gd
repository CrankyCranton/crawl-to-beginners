class_name Gun extends Marker2D


@export var magazine: Magazine

var cooling := false
var reloading := false

@onready var cooldown: Timer = $Cooldown
@onready var reload_time: Timer = $ReloadTime


func shoot() -> void:
	if magazine.ammo == 0 or cooling or reloading:
		return

	magazine.ammo -= 1
	var bullet: Node2D = magazine.ammo_type.instantiate()
	get_room().add_child(bullet)
	bullet.global_transform = global_transform


func reload(from_mag: Magazine) -> void:
	if reloading:
		return
	reloading = true
	magazine.reload(from_mag)
	reload_time.start()


func get_room() -> Node:
	var result: Node = get_parent()
	while result != get_tree().current_scene or result != get_node(^"/root") or not result is Room:
		result = result.get_parent()
	return result


func _on_cooldown_timeout() -> void:
	cooling = false


func _on_reload_time_timeout() -> void:
	reloading = false
