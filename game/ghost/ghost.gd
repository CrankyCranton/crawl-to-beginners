class_name Ghost extends Marker2D


const SPEED: float = 128.0

var velocity := Vector2()
var bounds: Rect2


func _physics_process(delta: float) -> void:
	var input: Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
	velocity = input * SPEED

	position += velocity * delta
	position = position.clamp(bounds.position, bounds.end)
