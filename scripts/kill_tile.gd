extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the colliding body is the player
	# The player scene uses CharacterBody2D and is named "CharacterBody2D" in level scenes
	if body.name == "CharacterBody2D" or body.is_in_group("player"):
		get_tree().reload_current_scene()
