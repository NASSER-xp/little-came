extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_open := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not is_open:
		is_open = true
		animated_sprite.play("default")
		print("It's a fake door! Tough luck!")
		# We could add a label popup here later if requested
