extends Node

const SAVE_PATH = "user://savegame.cfg"

var infinite_battery: bool = false
var unlocked_level: int = 1
var time_elapsed: float = 0.0
func _ready() -> void:
	load_game()

func save_game() -> void:
	var config = ConfigFile.new()
	config.set_value("progression", "unlocked_level", unlocked_level)
	config.set_value("settings", "infinite_battery", infinite_battery)
	config.save(SAVE_PATH)

func load_game() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		unlocked_level = config.get_value("progression", "unlocked_level", 1)
		infinite_battery = config.get_value("settings", "infinite_battery", false)

func _process(delta: float) -> void:
	var tree = get_tree()
	if tree and not tree.paused and tree.current_scene and tree.current_scene.name != "Control":
		time_elapsed += delta

func unlock_level(level: int) -> void:
	if level > unlocked_level:
		unlocked_level = level
		save_game()

func reset_progress() -> void:
	unlocked_level = 1
	save_game()
