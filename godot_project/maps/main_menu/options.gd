extends "res://maps/main_menu/options_and_levels.gd"

func _ready():
	var category_scene = load("res://maps/main_menu/option_category.tscn")
	for section in constanter.CATEGORY_TEXTS:
		var category = category_scene.instance()
		category.category_to_set = section
		grid.add_child(category)
	back_button.raise()
