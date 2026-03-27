extends Area2D

@onready var game_manager: Node = %gameManager
var energy_gain: float = 300.0
var max_energy_bonus: float = 0.0

func _on_body_entered(body: Node2D) -> void:
	if (body.name == "CharacterBody2D"):
		if max_energy_bonus > 0.0 and body.has_method("increase_max_energy"):
			body.increase_max_energy(max_energy_bonus)
		if body.has_method("add_energy"):
			body.add_energy(energy_gain)
		queue_free() # حذف العملة بعد الجمع
