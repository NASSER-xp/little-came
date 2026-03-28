extends Node


@onready var player = get_node("../CharacterBody2D")
@onready var energy_bar: ProgressBar = get_node("../ui/Panel2/ProgressBar") # أو EnergyBar حسب الاسم
@onready var dash_bar: ProgressBar = get_node_or_null("../ui/Panel2/DashBar")
@onready var infinite_button: Button = get_node_or_null("../ui/InfiniteBatteryButton")
@onready var debug_button: Button = get_node_or_null("../ui/DebugButton")
@onready var timer_label: Label = get_node_or_null("../ui/TimerLabel")


func _ready():
	if player and player.has_signal("energy_changed"):
		player.energy_changed.connect(_on_player_energy_changed)
		if energy_bar:
			energy_bar.max_value = player.max_energy
		_on_player_energy_changed(player.energy)
	
	if player and player.has_signal("dash_stamina_changed"):
		player.dash_stamina_changed.connect(_on_player_dash_stamina_changed)
		if dash_bar:
			dash_bar.max_value = player.max_dash_stamina
		_on_player_dash_stamina_changed(player.dash_stamina)

	if infinite_button:
		infinite_button.focus_mode = Control.FOCUS_NONE
		infinite_button.toggled.connect(_on_infinite_battery_button_toggled)
		infinite_button.button_pressed = GlobalState.infinite_battery
		_update_infinite_button_text()
		
		# Hide by default if we have a debug menu
		if debug_button:
			infinite_button.visible = debug_button.button_pressed
	
	if debug_button:
		debug_button.focus_mode = Control.FOCUS_NONE
		debug_button.toggled.connect(_on_debug_button_toggled)

func _on_player_energy_changed(value):
	if energy_bar:
		energy_bar.max_value = player.max_energy
		energy_bar.value = value

func _on_player_dash_stamina_changed(value):
	if dash_bar:
		dash_bar.value = value


func _on_infinite_battery_button_toggled(enabled: bool) -> void:
	GlobalState.infinite_battery = enabled
	if player and player.has_method("set_infinite_battery"):
		player.set_infinite_battery(enabled)
	_update_infinite_button_text()


func _on_debug_button_toggled(enabled: bool) -> void:
	if infinite_button:
		infinite_button.visible = enabled


func _update_infinite_button_text() -> void:
	if not infinite_button or not player:
		return
	infinite_button.text = "Infinity Battery: ON" if player.infinite_battery else "Infinity Battery: OFF"

func _process(_delta: float) -> void:
	if timer_label:
		var t = GlobalState.time_elapsed
		var time_str = "%02d:%02d.%02d" % [int(t / 60.0), int(t) % 60, int((t - int(t)) * 100)]
		timer_label.text = time_str
