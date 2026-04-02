class_name HitBox extends Area2D


signal damage_taken(damage: int)

# This is an additional check to prevent multiple hits within the same physics step.
var immune := false

@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var immune_timer: Timer = $ImmuneTimer


func take_damage(damage: int) -> bool:
	if immune:
		return false

	damage_taken.emit(damage)

	immune = true
	collision_shape.set_deferred(&"disabled", true)
	immune_timer.start()

	return true


func _on_immune_timer_timeout() -> void:
	immune = false
	collision_shape.set_deferred(&"disabled", false)
