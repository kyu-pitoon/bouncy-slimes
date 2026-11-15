extends Node2D
@onready var blue = $BlueSlime/AnimatedSprite2D
@onready var red = $RedSlime/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	blue.play("idle_blue")
	red.play("idle.red")
