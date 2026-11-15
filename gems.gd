extends Area2D

@onready var tile_map_layer: TileMapLayer = %TileMapLayer

func _on_body_entered(body):
	if body.name == 'RedSlime':
		hide()
		tile_map_layer.set_cell(Vector2i(7,-18),0,Vector2i(11,9))
		tile_map_layer.set_cell(Vector2i(8,-18),0,Vector2i(10,9))

func _ready():
	body_entered.connect(_on_body_entered)
