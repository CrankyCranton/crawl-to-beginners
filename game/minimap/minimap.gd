class_name Minimap extends GridContainer


func add_room(coords: Vector2i, mod: Room.Mod, unknown: bool) -> void:
	var room: MinimapRoom = preload("uid://bbowvsr77x6ag").instantiate()
	add_child(room)
	room.coords = coords
	room.mod = mod
	room.unknown = unknown


func set_unknown(coords: Vector2i, unknown: bool) -> void:
	for room: MinimapRoom in get_children():
		if room.coords == coords:
			room.unknown = unknown


func select_room(_coords: Vector2i) -> void:
	pass
