class_name HitBox extends Area2D


signal damage_taken(damage: int)

var immune := false

@onready var immune_timer: Timer = $ImmuneTimer


func take_damage(damage: int) -> bool:
	if immune and damage > 0:
		return false

	damage_taken.emit(damage)

	if damage > 0:
		immune = true
		immune_timer.start()
	return true


func _on_immune_timer_timeout() -> void:
	immune = false
