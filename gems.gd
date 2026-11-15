extends Area2D

@onready var tile_map_layer: TileMapLayer = %TileMapLayer

func _on_body_entered(body):
	if body.name == 'BlueSlime':
		hide()
		tile_map_layer.set_cell(Vector2i(0,-22),0,Vector2i(0,33))
		tile_map_layer.set_cell(Vector2i(1,-22),0,Vector2i(1,33))
		tile_map_layer.set_cell(Vector2i(0,-23),0,Vector2i(0,32))
		tile_map_layer.set_cell(Vector2i(1,-23),0,Vector2i(1,32))
		tile_map_layer.set_cell(Vector2i(0,-24),0,Vector2i(0,31))
		tile_map_layer.set_cell(Vector2i(1,-24),0,Vector2i(1,31))

func _ready():
	body_entered.connect(_on_body_entered)
