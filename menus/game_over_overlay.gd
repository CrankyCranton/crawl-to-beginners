class_name LoseOverlay extends ColorRect


signal try_again_pressed

@export var play_jingle := true


func _ready() -> void:
	MusicManager.set(&"parameters/switch_to_clip", &"mute" if play_jingle else &"menu")
	Engine.time_scale = 1.0
	get_tree().paused = true


func _on_try_again_button_pressed() -> void:
	get_tree().paused = false
	try_again_pressed.emit()


func _on_back_to_title_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_jingle_finished() -> void:
	MusicManager.set(&"parameters/switch_to_clip", &"menu")
