class_name HurtBox extends Area2D


# TODO: Might want to pass the remaining damage after hit box calculations later.
signal hit(hit_box: HitBox)

@export var damage: int = 1


func _on_area_entered(area: HitBox) -> void:
	if area.take_damage(damage):
		hit.emit(area)
