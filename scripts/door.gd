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
		
		# Detect current level number from scene name (e.g., "level10" -> 10, "game" -> 1)
		var current_scene_name = get_tree().current_scene.name.to_lower()
		var level_number = 1 if current_scene_name == "game" else int(current_scene_name.replace("level", ""))
		if level_number > 0:
			GlobalState.unlock_level(level_number + 1)
		
		if not next_scene_path.is_empty():
			# Wait for animation to finish or a small delay before changing scene
			await animated_sprite.animation_finished
			get_tree().change_scene_to_file(next_scene_path)
