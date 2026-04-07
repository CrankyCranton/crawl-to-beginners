class_name MinimapRoom extends Control


# TODO: Replace text with icons.
const TYPE_LOOKUP: Dictionary[Room.Mod, Texture2D] = {  }

var coords: Vector2i
var mod: Room.Mod:
	set(value):
		mod = value
		$Icon/TempLabel.text = Room.Mod.find_key(mod)
var unknown := false:
	set(value):
		unknown = value
		icon.visible = not unknown
		unknown_icon.visible = unknown

@onready var icon: TextureRect = $Icon
@onready var unknown_icon: TextureRect = $UnknownIcon


func _ready() -> void:
	custom_minimum_size.y = size.x
