extends Control

@onready var play_button: Button = $Button
@onready var settings_button: Button = $Button2
@onready var settings_menu: Control = $SettingsMenu
@onready var settings_close_button: Button = $SettingsMenu/CloseButton
@onready var resolution_option: OptionButton = $SettingsMenu/ResolutionOption
@onready var apply_button: Button = $SettingsMenu/ApplyButton

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
	settings_close_button.pressed.connect(_on_settings_close_pressed)
	resolution_option.item_selected.connect(_on_resolution_selected)
	apply_button.pressed.connect(_on_apply_pressed)
	_setup_resolution_options()
	_load_and_apply_resolution()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/game.tscn")

func _on_settings_pressed() -> void:
	settings_menu.visible = true

func _on_settings_close_pressed() -> void:
	settings_menu.visible = false

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

	# If the game is fullscreen/maximized, resizing may appear to do nothing.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(res)
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
