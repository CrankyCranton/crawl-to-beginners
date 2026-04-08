class_name Ghost extends CharacterBody2D


const SPEED: float = 256.0
# Potentially move this to the gun so that different guns can feel heavier than others.
const AIM_SPEED: float = 15.0
const POSSESS_FOLLOW_SPEED: float = 5.0

var possessing: CharacterBody2D = self
var can_possess := true
var room: Room

@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var sprite: Sprite2D = $Sprite
@onready var possession_detector: Area2D = $PossessionDetector


func _process(delta: float) -> void:
	if possessing.get(&"hand") != null:
		var hand: Node2D = possessing.hand
		var aim_angle: float = hand.global_position.angle_to_point(get_global_mouse_position())
		hand.global_rotation = lerp_angle(hand.global_rotation, aim_angle, AIM_SPEED * delta)


func _physics_process(delta: float) -> void:
	var input: Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
	possessing.velocity = input * SPEED
	possessing.move_and_slide()

	if possessing != self:
		global_position = global_position.lerp(possessing.global_position,
				POSSESS_FOLLOW_SPEED * delta)
	possession_detector.global_position = get_global_mouse_position()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"shoot"):
		if possessing.get(&"gun") != null:
			possessing.gun.shoot()

	if event.is_action_pressed(&"possess") and can_possess:
		var collider: Node2D = null
		# Making this a callable because repeating it twice in a one-liner was a pain,
		# but it seems too specific to the context be a general-purpose function.
		var poss_dist: Callable = func(a: Node2D) -> float:
			return possession_detector.global_position.distance_squared_to(a.global_position)
		for body: Node2D in possession_detector.get_overlapping_bodies():
			if body == possessing:
				continue
			if collider == null or poss_dist.call(body) < poss_dist.call(collider):
				collider = body

		if collider != null:
			if possessing != self:
				possessing.state = possessing.State.NORMAL
				possessing.died.disconnect(_on_possessing_died)
				if possessing is Enemy:
					possessing.reparent(room.enemies)
					room.set_up_enemy(possessing)
					#possessing.add_to_group(&"enemies")
					flip_mask()

			collider.died.connect(_on_possessing_died)
			possessing = collider
			if collider is Enemy:
				collider.reparent(get_parent())
				#collider.remove_from_group(&"enemies")
				flip_mask()
			collider.state = collider.State.POSSESSED
			#sprite.visible = possessing == self


# OK, the entire code base is messy, but this might just take the cake.
func flip_mask() -> void:
	const ENEMY_HIT_BOX: int = 11
	const HERO_HIT_BOX: int = 12
	possessing.gun.set_collision_mask_value(ENEMY_HIT_BOX,
			not possessing.gun.get_collision_mask_value(ENEMY_HIT_BOX))
	possessing.gun.set_collision_mask_value(HERO_HIT_BOX,
			not possessing.gun.get_collision_mask_value(HERO_HIT_BOX))

	possessing.hit_box.set_collision_layer_value(ENEMY_HIT_BOX,
			not possessing.hit_box.get_collision_layer_value(ENEMY_HIT_BOX))
	possessing.hit_box.set_collision_layer_value(HERO_HIT_BOX,
			not possessing.hit_box.get_collision_layer_value(HERO_HIT_BOX))


func set_light_enabled(enabled: bool) -> void:
	point_light_2d.enabled = enabled


func _on_possessing_died() -> void:
	possessing = self
