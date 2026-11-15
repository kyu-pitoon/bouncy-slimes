extends Node2D
@onready var slime = $CharacterBody2D/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	slime.play("move_right")
