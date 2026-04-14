class_name Bullet extends HurtBox
# NOTE: Change to ShapeCast2D if the bullet is too fast.


@export var speed: float = 128.0

var exceptions: Array[Node] = []

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta


func delete() -> void:
	collision_shape_2d.set_deferred(&"disabled", true)
	sprite.play(&"delete")
	#set_physics_process(false)


func _on_body_entered(body: Node2D) -> void:
	if body in exceptions:
		return
	delete()


func _on_hit(hit_box: HitBox) -> void:
	if hit_box in exceptions:
		return
	delete()


func _on_sprite_animation_finished() -> void:
	queue_free()
