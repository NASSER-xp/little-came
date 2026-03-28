extends Control

@onready var grid_container: GridContainer = $GridContainer
@onready var back_button: Button = $BackButton
@onready var reset_button: Button = $ResetButton
@onready var confirmation_panel: Panel = $Confirmation
@onready var confirm_reset_btn: Button = $Confirmation/ConfirmReset
@onready var cancel_reset_btn: Button = $Confirmation/CancelReset

var padlock_icon: Texture2D

func _ready() -> void:
	padlock_icon = load("res://assets/padlock_icon.svg")
	if not padlock_icon:
		# Fallback to PNG if SVG is not found
		padlock_icon = load("res://assets/padlock_icon.png")
		
	if not padlock_icon:
		printerr("CRITICAL: Failed to load padlock icon from assets (checked .svg and .png)")
	else:
		print("Padlock icon loaded successfully")
	
	back_button.pressed.connect(_on_back_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	confirm_reset_btn.pressed.connect(_on_confirm_reset_pressed)
	cancel_reset_btn.pressed.connect(_on_cancel_reset_pressed)
	
	print("Generating level buttons...")
	_generate_level_buttons()
	print("Done generating buttons. GridContainer child count: ", grid_container.get_child_count())

func _generate_level_buttons() -> void:
	# Clear existing buttons
	for child in grid_container.get_children():
		child.queue_free()
	
	var max_unlocked = GlobalState.unlocked_level
	
	for i in range(1, 21):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(80, 80)
		btn.text = str(i)
		
		if i <= max_unlocked:
			btn.pressed.connect(_on_level_btn_pressed.bind(i))
		else:
			btn.disabled = true
			btn.icon = padlock_icon
			btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn.expand_icon = true
			btn.text = "" # Hide number for locked levels as per user request (padlock icon only)
		
		grid_container.add_child(btn)

func _on_level_btn_pressed(level_num: int) -> void:
	var path = "res://scene/level%d.tscn" % level_num
	if level_num == 1:
		path = "res://scene/game.tscn" # Level 1 is currently game.tscn in this project
	
	if FileAccess.file_exists(path):
		get_tree().change_scene_to_file(path)
	else:
		printerr("Level scene not found: ", path)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/control.tscn")

func _on_reset_pressed() -> void:
	confirmation_panel.visible = true

func _on_confirm_reset_pressed() -> void:
	GlobalState.reset_progress()
	confirmation_panel.visible = false
	_generate_level_buttons()

func _on_cancel_reset_pressed() -> void:
	confirmation_panel.visible = false
