extends Area2D

@export var jump_force: float = -450.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.velocity.y = jump_force
