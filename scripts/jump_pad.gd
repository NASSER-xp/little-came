extends Area2D

@export var jump_force: float = -450.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		# Use Vector2.UP rotated by the jump pad's global rotation to determine push direction
		var push_direction = Vector2.UP.rotated(global_rotation)
		body.velocity = push_direction * abs(jump_force)
