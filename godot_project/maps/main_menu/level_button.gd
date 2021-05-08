extends "res://maps/main_menu/scrollable_button.gd"

var level = ""

func _ready():
	text = "Level " + str(int(level))
	var this_difficulty = config_loader.get_data("level_difficulties_done", level)
	if this_difficulty != config_loader.DIFFICULTY_NONE:
		theme = load(constanter.DIFFICULTY_BUTTON_PATHS[this_difficulty])
	if int(level) % 9 == 0:
		var new_theme = Theme.new()
		new_theme.copy_theme(theme)
		new_theme.default_font = theme.default_font
		var font_color = Color(0.95, 0.4, 0.4)
		new_theme.set_color("font_color", "Button", font_color)
		new_theme.set_color("font_color_hover", "Button", font_color)
		new_theme.set_color("font_color_disabled", "Button", font_color)
		theme = new_theme
	if int(level) > config_loader.get_data("misc", "first_uncompleted_level"):
		disabled = true
		focus_mode = FOCUS_NONE

func _on_level_button_scrollincluded_pressed():
	if communicator.is_currently_cheating:
		config_loader.set_data("misc", "first_uncompleted_level", int(level))
		communicator.is_currently_cheating = false
	music_player.fade_out()
	scene_transitioner.change_scene("res://maps/levels/" + level + ".tscn")
