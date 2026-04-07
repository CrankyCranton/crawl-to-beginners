class_name Fists extends HurtBox


var cooling := false
@warning_ignore("shadowed_global_identifier")
var range: float = 64.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func shoot() -> void:
	if cooling:
		return
	cooling = true
	animation_player.play(&"punch")
	await animation_player.animation_finished
	cooling = false
