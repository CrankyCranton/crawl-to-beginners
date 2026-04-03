class_name Room extends Node2D
# Max of 4 doors: 1 for each side.


var coords: Vector2i

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var enemies: Node2D = $Enemies
@onready var hero: Hero:
	set(value):
		hero = value
		for enemy: Enemy in enemies.get_children():
			enemy.hero = hero


func get_random_data() -> Dictionary:
	return {} # TBD


func generate(generation_data: Dictionary) -> void:
	# TODO: Generate doors from the data.
	for cell: Vector2i in tile_map_layer.get_used_cells():
		var tile_data: TileData = tile_map_layer.get_cell_tile_data(cell)
		if tile_data.has_custom_data("type"):
			match tile_data.get_custom_data("type"):
				pass
