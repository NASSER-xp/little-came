extends Node


@onready var player = get_node("../CharacterBody2D")
@onready var energy_bar: ProgressBar = get_node("../ui/Panel2/ProgressBar") # أو EnergyBar حسب الاسم
@onready var infinite_button: Button = get_node_or_null("../ui/InfiniteBatteryButton")



func _ready():
	if player and player.has_signal("energy_changed"):
		player.energy_changed.connect(_on_player_energy_changed)
		if energy_bar:
			energy_bar.max_value = player.max_energy
		_on_player_energy_changed(player.energy)
	if infinite_button:
		infinite_button.focus_mode = Control.FOCUS_NONE
		infinite_button.toggled.connect(_on_infinite_battery_button_toggled)
		infinite_button.button_pressed = player.infinite_battery
		_update_infinite_button_text()

func _on_player_energy_changed(value):
	if energy_bar:
		energy_bar.value = value


func _on_infinite_battery_button_toggled(enabled: bool) -> void:
	if not player or not player.has_method("set_infinite_battery"):
		return
	player.set_infinite_battery(enabled)
	_update_infinite_button_text()


func _update_infinite_button_text() -> void:
	if not infinite_button or not player:
		return
	infinite_button.text = "Infinity Battery: ON" if player.infinite_battery else "Infinity Battery: OFF"
