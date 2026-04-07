class_name Explosion extends Area2D


const DAMAGE: int = 1

var hit_list: Array[HitBox] = []

@onready var los: RayCast2D = $LOS


func _on_area_entered(area: HitBox) -> void:
	if area in hit_list:
		return
	los.target_position = los.to_local(area.global_position)
	los.force_raycast_update()
	if not los.is_colliding():
		area.take_damage(DAMAGE)
		hit_list.append(area)
