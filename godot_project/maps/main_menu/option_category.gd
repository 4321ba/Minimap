extends VBoxContainer

var category_to_set

onready var category_grid = $category_grid
onready var category_label = $category_label

func _ready():
	category_label.text = constanter.CATEGORY_TEXTS[category_to_set]
	var button_scene = load("res://maps/main_menu/option_button.tscn")
	for setting in constanter.OPTION_CATEGORIES[category_to_set]:
		var button = button_scene.instance()
		button.option_to_set = setting
		category_grid.add_child(button)
	if len(constanter.OPTION_CATEGORIES[category_to_set]) % 2 == 1:
		var placeholder = load("res://maps/main_menu/button.tscn").instance()
		placeholder.visible = false
		category_grid.add_child(placeholder)
		
