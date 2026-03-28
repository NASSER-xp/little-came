extends Control

@onready var play_button: Button = $Button
@onready var settings_button: Button = $Button2
@onready var settings_menu: Control = $SettingsMenu
@onready var settings_close_button: Button = $SettingsMenu/CloseButton
@onready var resolution_option: OptionButton = $SettingsMenu/ResolutionOption
@onready var apply_button: Button = $SettingsMenu/ApplyButton
@onready var fullscreen_checkbox: CheckBox = $SettingsMenu/CheckBox
@onready var levels_button: Button = $Levels
@onready var exit: Button = $Exit

const SETTINGS_PATH := "user://settings.cfg"
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]
var pending_resolution_index: int = 0

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	levels_button.pressed.connect(_on_levels_pressed)
	settings_close_button.pressed.connect(_on_settings_close_pressed)
	resolution_option.item_selected.connect(_on_resolution_selected)
	apply_button.pressed.connect(_on_apply_pressed)
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	_setup_resolution_options()
	_load_and_apply_resolution()
	
	fullscreen_checkbox.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/game.tscn")

func _on_settings_pressed() -> void:
	settings_menu.visible = true
	play_button.visible = false
	settings_button.visible = false
	levels_button.visible = false
	exit.visible = false
	
	
	

func _on_settings_close_pressed() -> void:
	settings_menu.visible = false
	play_button.visible = true
	settings_button.visible = true
	levels_button.visible = true
	exit.visible = true

func _on_levels_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/levels_menu.tscn")


func _setup_resolution_options() -> void:
	resolution_option.clear()
	for res in RESOLUTIONS:
		resolution_option.add_item("%d x %d" % [res.x, res.y])
	resolution_option.select(pending_resolution_index)

func _on_resolution_selected(index: int) -> void:
	if index < 0 or index >= RESOLUTIONS.size():
		return
	pending_resolution_index = index

func _on_apply_pressed() -> void:
	if pending_resolution_index < 0 or pending_resolution_index >= RESOLUTIONS.size():
		return
	_apply_resolution(RESOLUTIONS[pending_resolution_index], true)

func _save_resolution(res: Vector2i) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "width", res.x)
	cfg.set_value("video", "height", res.y)
	cfg.save(SETTINGS_PATH)

func _apply_resolution(res: Vector2i, save: bool) -> void:
	# When running "embedded" in the editor, the game window can't be resized/moved.
	# Still save the chosen resolution so it works in exported / normal window runs.
	if OS.has_feature("editor"):
		if save:
			_save_resolution(res)
		return

	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		# Just change the internal resolution for upscaling in fullscreen
		get_window().content_scale_size = res
	else:
		# Change actual window size
		DisplayServer.window_set_size(res)
		get_window().content_scale_size = res

	if save:
		_save_resolution(res)

func _load_and_apply_resolution() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return

	var w: int = int(cfg.get_value("video", "width", 0))
	var h: int = int(cfg.get_value("video", "height", 0))
	if w <= 0 or h <= 0:
		return

	var res := Vector2i(w, h)
	_apply_resolution(res, false)

	for i in range(RESOLUTIONS.size()):
		if RESOLUTIONS[i] == res:
			pending_resolution_index = i
			resolution_option.select(pending_resolution_index)
			return


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_Exit_pressed() -> void:
	get_tree().quit()
