class_name Enemy extends CharacterBody2D


signal died
signal removed
signal shot(ammo: int, cooldown: float)

enum State {
	NORMAL,
	POSSESSED,
}

const SOFT_COLLISION_INFLUENCE: float = 0.5
# Squared to save on performance when compairing distances to it.
const PATH_DESIRED_DISTANCE: float = pow(8.0, 2.0)

@export var speed: float = 72.0
@export var aim_speed: float = 15.0
@export var aim_margin: float = 1.0
@export var gun: Node2D:
	set(value):
		gun = value
		if gun:
			gun.shot.connect(shot.emit)
@export var health: int = 2:
	set(value):
		if value < health:
			Utils.hit_flash(sprite)
			hurt_sound.play()
		health = value
		if health <= 0:
			die()

var dead := false
var hero: Hero
var last_target_pos := Vector2i.MAX
var astar: AStarGrid2D
var path: PackedVector2Array = []
var room: Room
var state: State = State.NORMAL:
	set(value):
		state = value
		if state == State.POSSESSED:
			removed.emit()

@onready var soft_collision: SoftCollision = $SoftCollision
@onready var hand: Marker2D = $Hand
@onready var los: ShapeCast2D = %LOS
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent
@onready var hit_box: HitBox = $HitBox
@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get(&"parameters/playback")
@onready var sprite: Sprite2D = $Sprite
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var max_health: int = health
@onready var label_animator: AnimationPlayer = $EmpyLabel/LabelAnimator
@onready var anim_dir := Vector2.DOWN:
	set(value):
		anim_dir = value
		animation_tree.set(&"parameters/idle/blend_position", anim_dir)
		animation_tree.set(&"parameters/walk/blend_position", anim_dir)


func _ready() -> void:
	hand.rotation = randf() * TAU
	aim_margin = deg_to_rad(aim_margin)
	los.add_exception(self)
	gun.mag_empty.connect(_on_gun_mag_empty)


func _physics_process(delta: float) -> void:
	match state:
		State.NORMAL:
			var target: Node2D = _get_target()
			if target == null:
				return
			var target_pos: Vector2 = target.global_position

			var target_angle: float = hand.global_position.angle_to_point(target_pos)
			hand.global_rotation = lerp_angle(hand.global_rotation,
					target_angle, aim_speed * delta)
			los.target_position = los.to_local(target_pos)
			var aim_accuracy: float = absf(hand.global_transform.x.angle_to(
					hand.global_position.direction_to(target_pos)))

			if (gun.global_position.distance_to(target_pos) <= gun.range
					and _extra_shoot_conds() and aim_accuracy <= aim_margin
					and not los.is_colliding()):
				gun.shoot()
			#else:
			var target_cell_pos: Vector2i = room.get_cell_id(target_pos)
			if last_target_pos != target_cell_pos:
				last_target_pos = target_cell_pos
				path = astar.get_point_path(room.get_cell_id(global_position), target_cell_pos)
				if path.size() > 0:
					path.remove_at(0)

			if path.size() > 0:
				#navigation_agent.target_position = hero.global_position
				#var straight_direction: Vector2 = global_position.direction_to(
						#navigation_agent.get_next_path_position())
				var straight_direction: Vector2 = position.direction_to(path[0])

				var soft_vector: Vector2 = soft_collision.get_vector() * SOFT_COLLISION_INFLUENCE
				velocity = (straight_direction + soft_vector).normalized() * speed
				move_and_slide()

				if position.distance_squared_to(path[0]) <= PATH_DESIRED_DISTANCE:
					path.remove_at(0)

			#queue_redraw()

	animate()


#func _draw() -> void:
	#for i in path.size() - 1:
		#draw_line(to_local(path[i]), to_local(path[i + 1]), Color.RED, 1.0)


func _get_target() -> Node2D:
	return hero


func _extra_shoot_conds() -> bool:
	return true


func animate() -> void:
	var anim_state: StringName = &"walk" if velocity != Vector2.ZERO else &"idle"
	if anim_state != playback.get_current_node():
		playback.travel(anim_state)
	if anim_state == &"walk":
		anim_dir = velocity.normalized()


func die() -> void:
	dead = true
	collision_shape.set_deferred(&"disabled", true)
	remove_from_group(&"enemies")
	var death_effect: AnimatedSprite2D = preload("uid://dwxvg56mqxrq3").instantiate()
	get_tree().current_scene.add_child(death_effect)
	death_effect.global_position = global_position
	removed.emit()
	died.emit()
	queue_free()


func drop_gun() -> void:
	gun.queue_free()
	var fists: Fists = preload("uid://cap0tc1j8ohhe").instantiate()
	fists.collision_mask = gun.collision_mask
	hand.add_child(fists)
	gun = fists


func _on_hit_box_damage_taken(damage: int) -> void:
	health -= damage


func _on_gun_mag_empty() -> void:
	drop_gun()
