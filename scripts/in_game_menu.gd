extends Control

@onready var menu_button: Button = $MenuButton
@onready var menu_panel: Control = $MenuPanel
@onready var restart_button: Button = $MenuPanel/VBoxContainer/RestartButton
@onready var quit_button: Button = $MenuPanel/VBoxContainer/QuitButton

func _ready() -> void:
	menu_panel.visible = false
	menu_button.pressed.connect(_on_menu_button_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_menu_button_pressed() -> void:
	menu_panel.visible = !menu_panel.visible
	get_tree().paused = menu_panel.visible

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/control.tscn")
