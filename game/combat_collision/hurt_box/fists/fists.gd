class_name Fists extends HurtBox


signal shot(ammo: int, cooldown: float)

var cooling := false
@warning_ignore("shadowed_global_identifier")
var range: float = 64.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite


func _process(_delta: float) -> void:
	sprite.flip_h = sprite.global_transform.y.x < 0.0


func shoot() -> void:
	if cooling:
		return
	cooling = true
	animation_player.play(&"punch")
	shot.emit(-1, get_remaining_time())
	await animation_player.animation_finished
	cooling = false


func get_remaining_time() -> float:
	return (animation_player.current_animation_length
			- animation_player.current_animation_position) * float(animation_player.is_playing())
