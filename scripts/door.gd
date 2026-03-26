extends Area2D

@export_file("*.tscn") var next_scene_path: String
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_open := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not is_open:
		is_open = true
		animated_sprite.play("default")
		if not next_scene_path.is_empty():
			# Wait for animation to finish or a small delay before changing scene
			await animated_sprite.animation_finished
			get_tree().change_scene_to_file(next_scene_path)
