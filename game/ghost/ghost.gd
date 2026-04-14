class_name Ghost extends CharacterBody2D


signal shot(ammo: int, cooldown: float)

const SPEED: float = 256.0
# Potentially move this to the gun so that different guns can feel heavier than others.
const AIM_SPEED: float = 15.0
const POSSESS_FOLLOW_SPEED: float = 5.0
const HERO_POSSESS_PREFERENCE: float = 2.0
const POSSESSION_SHADER: ShaderMaterial = preload("res://game/vfx/possession.material")
const PRE_POSSESSION_SHADER: ShaderMaterial = preload("res://game/vfx/pre_possession.material")

var room: Room
var can_possess := true
var possessing: CharacterBody2D = self:
	set(value):
		possessing = value
		if not possessing is Enemy:
			shot.emit(0, 0.0)
		else:
			if possessing.gun is Fists:
				shot.emit(-1, possessing.gun.get_remaining_time())
			else:
				shot.emit(possessing.gun.magazine.ammo, possessing.gun.cooldown.time_left)

@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var sprite: Sprite2D = $Sprite
@onready var possession_detector: Area2D = $PossessionDetector
@onready var possess_notifier: Marker2D = $PossessNotifier


func _ready() -> void:
	POSSESSION_SHADER.set_shader_parameter(&"number_of_images", Vector2.ONE)


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

	var collider: Node2D = null
	var poss_dist: Callable = func(a: Node2D) -> float:
		return possession_detector.global_position.distance_squared_to(a.global_position)
	for body: Node2D in possession_detector.get_overlapping_bodies():
		if body != possessing:
			var body_dist: float = poss_dist.call(body)
			if body is Hero:
				body_dist /= HERO_POSSESS_PREFERENCE
			if (collider == null or body_dist < poss_dist.call(collider)):
				if can_possess:
					collider = body
			else:
				body.material = null
				body.get_node(^"Sprite").z_index = 0

	var target: Vector2 = (collider if collider != null else possession_detector).global_position
	possess_notifier.position = possess_notifier.position.lerp(target, 10.0 * delta)
	possess_notifier.modulate.a = move_toward(possess_notifier.modulate.a,
			float(collider != null), 10.0 * delta)

	if collider:
		collider.material = PRE_POSSESSION_SHADER
		@warning_ignore("shadowed_variable")
		var sprite: Sprite2D = possessing.get_node(^"Sprite")
		var grid_size := Vector2(sprite.hframes, sprite.vframes)
		PRE_POSSESSION_SHADER.set_shader_parameter(&"number_of_images", grid_size)
		collider.get_node(^"Sprite").z_index = 1


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
			var body_dist: float = poss_dist.call(body)
			if body is Hero:
				body_dist /= HERO_POSSESS_PREFERENCE
			if collider == null or body_dist < poss_dist.call(collider):
				collider = body

		if collider != null:
			possessing.material = null
			if possessing != self:
				possessing.state = possessing.State.NORMAL
				possessing.died.disconnect(_on_possessing_died)
				possessing.material = null
				if possessing is Enemy:
					possessing.shot.disconnect(shot.emit)
					possessing.reparent(room.enemies)
					room.set_up_enemy(possessing)
					possessing.add_to_group(&"enemies")
					flip_mask()

			possessing = collider
			possessing.material = POSSESSION_SHADER
			@warning_ignore("shadowed_variable")
			var sprite: Sprite2D = possessing.get_node(^"Sprite")
			var grid_size := Vector2(sprite.hframes, sprite.vframes)
			POSSESSION_SHADER.set_shader_parameter(&"number_of_images", grid_size)
			if collider is Enemy:
				possessing.shot.connect(shot.emit)
				collider.reparent(get_parent())
				collider.remove_from_group(&"enemies")
				flip_mask()
			collider.state = collider.State.POSSESSED
			#sprite.visible = possessing == self
			collider.died.connect(_on_possessing_died)


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


func _on_possession_detector_body_exited(body: Node2D) -> void:
	if body != possessing:
		body.material = null
		body.get_node(^"Sprite").z_index = 0
