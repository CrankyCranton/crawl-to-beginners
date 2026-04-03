class_name Bullet extends HurtBox
# NOTE: Change to ShapeCast2D if the bullet is too fast.


@export var speed: float = 256.0


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta


func delete() -> void:
	queue_free()


func _on_body_entered(_body: Node2D) -> void:
	delete()


func _on_hit(_hit_box: HitBox) -> void:
	delete()
