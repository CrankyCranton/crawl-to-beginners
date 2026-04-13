class_name Bullet extends HurtBox
# NOTE: Change to ShapeCast2D if the bullet is too fast.


@export var speed: float = 128.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta


func delete() -> void:
	collision_shape_2d.set_deferred(&"disabled", true)
	sprite.play(&"delete")
	#set_physics_process(false)


func _on_body_entered(_body: Node2D) -> void:
	delete()


func _on_hit(_hit_box: HitBox) -> void:
	delete()


func _on_sprite_animation_finished() -> void:
	queue_free()
