extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var lever_area: Area2D = $LeverArea2D

# Update these to match your TileSet's Source ID and Atlas Coordinates
var source_id: int = 0
var lever_off_atlas_coords: Vector2i = Vector2i(4, 49) # the not flicked lever tile
var lever_on_atlas_coords: Vector2i = Vector2i(5, 49) # The "flicked" lever tile
var block_atlas_coords: Vector2i = Vector2i(10, 6)   # The tile you want to appear

# For the OTHER tiles (like a bridge or door), list their grid coordinates
var tiles_to_toggle: Array[ Vector2i] = [
	Vector2i(4, -6),
	Vector2i(5, -6),
	Vector2i(-4, -16),
	Vector2i(-3, -16),

]

var is_flicked: bool = false

func _on_lever_area_2d_body_entered(body: Node2D) -> void:
	# Check if the entering body is your CharacterBody2D (and prevent re-triggering)
	if body is CharacterBody2D:
		flick_lever()

func flick_lever() -> void:
	# 1. Automatically find the lever's Vector2i using the Area2D's position
	var lever_cell: Vector2i = Vector2i(-2, -10)
	
	# 2. Update the lever tile to its "flicked" version
	if is_flicked:
		tile_map_layer.set_cell(lever_cell, source_id, lever_off_atlas_coords)
		for cell_pos in tiles_to_toggle:
			tile_map_layer.erase_cell(cell_pos)		
	else:
		tile_map_layer.set_cell(lever_cell, source_id, lever_on_atlas_coords)
		for cell_pos in tiles_to_toggle:
			tile_map_layer.set_cell(cell_pos, source_id, block_atlas_coords)
		

	is_flicked = !is_flicked
	
