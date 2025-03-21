extends Node

@onready var points_label: Label = %"points label"

var points = 0

func add_point():
	points += 1
	print(points)
	points_label.text = "points: " + str(points)
