extends "res://maps/main_menu/options_and_levels.gd"

func _ready():
	var button_scene = load("res://maps/main_menu/level_button.tscn")
	for level in config_loader.levels:
		var button = button_scene.instance()
		button.level = level
		grid.add_child(button)
	back_button.raise()
