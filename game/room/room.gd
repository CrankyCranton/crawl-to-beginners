class_name Room extends Node2D
# Max of 4 doors: 1 for each side.


@export var heatmap_color: Gradient

var coords: Vector2i
var astar := AStarGrid2D.new()
var astar_heatmap := AStarGrid2D.new()

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var enemies: Node2D = $Enemies
@onready var hero: Hero:
	set(value):
		hero = value
		hero.astar = astar_heatmap
		for enemy: Enemy in enemies.get_children():
			enemy.hero = hero


func _process(_delta: float) -> void:
	const ENEMY_RANGE: float = 192.0
	const MAX_ENEMY_WEIGHT: float = 8.0
	const BULLET_RANGE: float = 256.0
	const MAX_BULLET_WEIGHT: float = 4.0

	for y: int in range(astar_heatmap.region.position.y, astar_heatmap.region.end.y):
		for x: int in range(astar_heatmap.region.position.x, astar_heatmap.region.end.x):
			var cell := Vector2i(x, y)
			#if astar_heatmap.is_point_solid(cell):
				#continue

			var weight_scale: float = 1.0

			var heat_nodes: Array[Node] = enemies.get_children()
			heat_nodes.append_array(get_tree().get_nodes_in_group(&"bullets"))
			for heat_node: Node in heat_nodes:
				var length: float = 0.0
				var path: PackedVector2Array = astar.get_point_path(
						Room.get_cell_id(heat_node.global_position, astar.cell_size), cell)
				for i: int in range(1, path.size()):
					length += path[i - 1].distance_to(path[i])

				var heat_range: float = BULLET_RANGE if heat_node is Bullet else ENEMY_RANGE
				length = minf(length, heat_range)
				var max_weight: float = (MAX_BULLET_WEIGHT
						if heat_node is Bullet else MAX_ENEMY_WEIGHT)
				weight_scale *= remap(length, 0.0, heat_range, max_weight, 1.0)

			astar_heatmap.set_point_weight_scale(cell, weight_scale)

	queue_redraw()


# WARNING:
# Sometimes this can make the map flash bright red when
# there aren't many enemies on the map and you shoot.
# Could be hard on the eyes.
#func _draw() -> void:
	#for point_data: Dictionary in astar_heatmap.get_point_data_in_region(astar_heatmap.region):
		#var rect := Rect2(point_data.position - astar_heatmap.offset, astar_heatmap.cell_size)
		#var color: Color = heatmap_color.sample(remap(point_data.weight_scale, 1.0, 32.0, 0.0, 1.0))
		#draw_rect(rect, color)
		#draw_rect(rect, Color(1.0, 1.0, 1.0, 0.1), false, 1.0)


func get_random_data() -> Dictionary:
	return {} # TBD


func generate(generation_data: Dictionary) -> void:
	# TODO: Generate doors from the data.

	init_astar_grid(astar)
	init_astar_grid(astar_heatmap)

	for cell: Vector2i in tile_map_layer.get_used_cells():
		astar.set_point_solid(cell)
		astar_heatmap.set_point_solid(cell)

		var tile_data: TileData = tile_map_layer.get_cell_tile_data(cell)
		if tile_data.has_custom_data("type"):
			match tile_data.get_custom_data("type"):
				pass

	for enemy: Enemy in enemies.get_children():
		enemy.astar = astar_heatmap


func init_astar_grid(astar_grid: AStarGrid2D) -> void:
	#astar_grid.jumping_enabled = true
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.region = tile_map_layer.get_used_rect()
	astar_grid.cell_size = tile_map_layer.tile_set.tile_size
	astar_grid.offset = astar_grid.cell_size / 2.0
	astar_grid.update()


static func get_cell_id(pos: Vector2, cell_size: Vector2) -> Vector2i:
	return Vector2i((pos / cell_size).floor())
