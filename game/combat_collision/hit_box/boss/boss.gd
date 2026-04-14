class_name Boss extends HitBox


signal died

const MAX_HEALTH: int = 30
const MIN_IDLE_TIME: float = 1.0
const MAX_IDLE_TIME: float = 2.0
const RAMPAGE_SPEED: float = 2.0
const FAKE_CHANCE: float = 0.2

@export var randomizations: Dictionary[Node2D, float] = {  }

var hero: Hero
var rampaging := false

@onready var guns: Node2D = $Guns
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var static_body: StaticBody2D = $StaticBody
@onready var health_bar: ProgressBar = %HealthBar
@onready var sprite: Sprite2D = $Sprite
@onready var health: int = MAX_HEALTH:
	set(value):
		health = value
		health_bar.value = float(health) / MAX_HEALTH
		Utils.hit_flash(sprite)
		if health <= 0:
			died.emit()


func _ready() -> void:
	idle()
	for gun_type: Node2D in guns.get_children():
		for gun: Gun in gun_type.get_children():
			gun.exceptions.append(static_body)


func _process(_delta: float) -> void:
	for gun_type: Node2D in guns.get_children():
		for gun: Gun in gun_type.get_children():
			gun.look_at(hero.global_position)


func shoot(gun_type: NodePath) -> void:
	var gun_type_node: Node2D = get_node(gun_type)
	var randomization: float = randomizations[gun_type_node]
	for gun: Gun in gun_type_node.get_children():
		gun.rotate(deg_to_rad(randf() * randomization - randomization / 2.0))
		gun.shoot()


func idle() -> void:
	var time: float = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)
	if rampaging:
		time /= RAMPAGE_SPEED

	await get_tree().create_timer(time, false).timeout
	animation_player.play(&"warning", -1, RAMPAGE_SPEED if rampaging else 1.0)


func _on_damage_taken(damage: int) -> void:
	health -= damage


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		&"warning":
			if randf() > FAKE_CHANCE:
				animation_player.play(&"pre_shoot", -1, RAMPAGE_SPEED if rampaging else 1.0)
			else:
				idle()
		&"pre_shoot":
			var anims: Array[StringName] = [&"shoot_grenades", &"shoot_pistols", &"shoot_snipers"]
			animation_player.play(anims.pick_random())
		_:
			idle()
