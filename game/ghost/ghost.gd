class_name Ghost extends CharacterBody2D


const SPEED: float = 144.0
# Potentially move this to the gun so that different guns can feel heavier than others.
const AIM_SPEED: float = 15.0

@onready var hand: Marker2D = $Hand
@onready var gun: Gun = $Hand/Gun # Temp. TODO: Change with dynamic gun switching.


func _process(delta: float) -> void:
	var aim_angle: float = hand.global_position.angle_to_point(get_global_mouse_position())
	hand.global_rotation = lerp_angle(hand.global_rotation, aim_angle, AIM_SPEED * delta)


func _physics_process(_delta: float) -> void:
	var input: Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
	velocity = input * SPEED
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"shoot"):
		gun.shoot()
