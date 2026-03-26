extends Area2D

@export_file("*.tscn") var next_scene_path: String


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if next_scene_path.is_empty():
		return
	if body.name != "CharacterBody2D":
		return
	get_tree().change_scene_to_file(next_scene_path)
