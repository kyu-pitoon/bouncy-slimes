extends Area2D

func _on_body_entered(body):
	if body.name == 'RedSlime':
		hide()

func _ready():
	body_entered.connect(_on_body_entered)
