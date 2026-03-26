extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not animated_sprite.is_playing():
		animated_sprite.play("default")

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		animated_sprite.stop()
		animated_sprite.frame = 0
