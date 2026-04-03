class_name Ghost extends CharacterBody2D


const SPEED: float = 128.0


func _physics_process(_delta: float) -> void:
	var input: Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
	velocity = input * SPEED
	move_and_slide()
