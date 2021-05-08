extends "res://maps/main_menu/scrollable_button.gd"

var option_to_set = ""
var cheat_pressed_count = 0

func _ready():
	if (OS.get_name() == "Android" or OS.get_name() == "HTML5") and (option_to_set == "fullscreen" or option_to_set == "vsync"):
		queue_free()
		return
	set_option_name()
	if option_to_set == "difficulty":
		update_difficulty_color()

func _on_option_button_scrollincluded_pressed():
	if constanter.OPTION_TEXTS[option_to_set].size() == 2:
		config_loader.set_data("settings", option_to_set, not config_loader.get_data("settings", option_to_set))
	else:
		var set_to = config_loader.get_data("settings", option_to_set) + 1
		if set_to >= constanter.OPTION_TEXTS[option_to_set].size():
			set_to = 0
		config_loader.set_data("settings", option_to_set, set_to)
	set_option_name()
	if option_to_set == "sound_effects" or option_to_set == "music":
		config_loader.refresh_audio(option_to_set)
	elif option_to_set == "animated_menu":
		communicator.animated_menu.refresh_animation_state()
	elif option_to_set == "lighting":
		communicator.ground.refresh_tiles()
		communicator.animated_menu.refresh_light_state()
		config_loader.refresh_clear_color()
	elif option_to_set == "fullscreen":
		config_loader.refresh_fullscreen()
	elif option_to_set == "vsync":
		config_loader.refresh_vsync()
	elif option_to_set == "difficulty":
		update_difficulty_color()
	elif option_to_set == "show_scrollbar":
		communicator.options_and_levels.refresh_scrollbar_visibility()
		if communicator.CAN_CHEAT:
			cheat_pressed_count += 1
			if cheat_pressed_count == 10:
				communicator.is_currently_cheating = true
				config_loader.set_data("misc", "first_uncompleted_level", 1000)

func set_option_name():
	text = constanter.OPTION_TEXTS[option_to_set][int(config_loader.get_data("settings", option_to_set))]

func update_difficulty_color():
	theme = load(constanter.DIFFICULTY_BUTTON_PATHS[config_loader.get_data("settings", "difficulty")])
