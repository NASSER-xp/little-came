extends Node


@onready var player = get_node("../CharacterBody2D")
@onready var energy_bar: ProgressBar = get_node("../ui/Panel2/ProgressBar") # أو EnergyBar حسب الاسم



func _ready():
	if player and player.has_signal("energy_changed"):
		player.energy_changed.connect(_on_player_energy_changed)
		_on_player_energy_changed(player.energy)

func _on_player_energy_changed(value):
	if energy_bar:
		energy_bar.value = value
