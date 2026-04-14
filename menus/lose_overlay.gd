class_name LoseOverlay extends ColorRect


func _ready() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = true


func _on_try_again_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_back_to_title_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
