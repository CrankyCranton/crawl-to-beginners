class_name MainMenu extends Control


func _ready() -> void:
	MusicManager.set(&"parameters/switch_to_clip", &"menu")


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/game.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
