extends "res://maps/main_menu/options_and_levels.gd"

func _ready():
	var category_scene = load("res://maps/main_menu/help_category.tscn")
	for title in constanter.help:
		var scene = category_scene.instance()
		scene.title = title
		scene.description = constanter.help[title]
		grid.add_child(scene)
	back_button.raise()
