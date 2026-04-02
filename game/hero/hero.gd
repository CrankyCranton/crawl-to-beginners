class_name Hero extends CharacterBody2D


const SPEED: float = 128.0

enum State {
	NORMAL,
	AFRAID,
	POSSESSED,
}

var state: State = State.NORMAL

@onready var soft_collision: SoftCollision = $SoftCollision


func _physics_process(_delta: float) -> void:
	match state:
		State.NORMAL:
			# NOTE: Also factor in following the ghost?
			velocity = soft_collision.get_vector() * SPEED
		State.AFRAID:
			# NOTE: Can use a looping timer to randomly set the direction,
			# with priority towards away from the enemy.
			pass
		State.POSSESSED:
			pass

	move_and_slide()
