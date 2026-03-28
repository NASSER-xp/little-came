extends Node

var infinite_battery: bool = false
var time_elapsed: float = 0.0

func _process(delta: float) -> void:
	if not get_tree().paused and get_tree().current_scene and get_tree().current_scene.name != "Control":
		time_elapsed += delta
