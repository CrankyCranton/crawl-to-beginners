class_name Hero extends CharacterBody2D


const SPEED: float = 128.0

enum State {
	NORMAL, # Navigates to random points on the map.
	AFRAID, # Normal but sped up and with randomness.
	FOLLOW, # Follow the player outside of combat.
}

var state: State = State.NORMAL
var max_health: int = 3:
	set(value):
		max_health = value
		health = health
var health: int = max_health:
	set(value):
		health = mini(max_health, value)

@onready var soft_collision: SoftCollision = $SoftCollision
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent


func _physics_process(_delta: float) -> void:
	match state:
		State.NORMAL:
			velocity = soft_collision.get_vector() * SPEED
		State.AFRAID:
			# NOTE: Can use a looping timer to randomly set the direction,
			# with priority towards away from the enemy.
			pass
		State.FOLLOW:
			pass

	move_and_slide()


func _on_hit_box_damage_taken(damage: int) -> void:
	health -= damage
