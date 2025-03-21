extends Area2D

@onready var game_manager: Node = %gameManager

func _on_body_entered(body: Node2D) -> void:
	if (body.name == "CharacterBody2D"):
		queue_free() # Replace with function body.
		game_manager.add_point()
