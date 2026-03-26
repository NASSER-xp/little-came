extends Area2D

@onready var game_manager: Node = %gameManager

func _on_body_entered(body: Node2D) -> void:
	if (body.name == "CharacterBody2D"):
		if body.has_method("add_energy"):
			body.add_energy(200)
		queue_free() # حذف العملة بعد الجمع
		
