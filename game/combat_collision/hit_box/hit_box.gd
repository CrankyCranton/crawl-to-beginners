class_name HitBox extends Area2D


signal damage_taken(damage: int)

var immune := false

@onready var immune_timer: Timer = $ImmuneTimer


func take_damage(damage: int) -> bool:
	if immune:
		return false

	damage_taken.emit(damage)

	immune = true
	immune_timer.start()
	return true


func _on_immune_timer_timeout() -> void:
	immune = false
