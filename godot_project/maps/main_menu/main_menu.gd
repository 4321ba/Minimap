extends Control

onready var levels_button = $MarginContainer/HBoxContainer/VBoxContainer/levels_button
onready var quit_button = $MarginContainer/HBoxContainer/VBoxContainer/quit_button

func _ready():
	if OS.get_name() == "HTML5":
		quit_button.queue_free()
	levels_button.grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel") and config_loader.get_data("settings", "use_touch_input"):
		quit_button.get_node("click").play()
		quit()

func _on_levels_button_pressed():
	communicator.animated_menu.change_to_menu(communicator.LEVELS)

func _on_skills_button_pressed():
	communicator.animated_menu.change_to_menu(communicator.SKILLS)

func _on_options_button_pressed():
	communicator.animated_menu.change_to_menu(communicator.OPTIONS)

func _on_help_button_pressed():
	communicator.animated_menu.change_to_menu(communicator.HELP)

func _on_quit_button_pressed():
	quit()

func quit():
	yield(quit_button.get_node("click"), "finished")
	get_tree().quit()
