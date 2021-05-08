extends Control

onready var back_button = $MarginContainer/VBoxContainer/MarginContainer/back_button
onready var grid = $MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/GridContainer
onready var scroll_container = $MarginContainer/VBoxContainer/ScrollContainer

func _ready():
	communicator.options_and_levels = self
	back_button.grab_focus()
	scroll_container.get_v_scrollbar().light_mask = 0
	refresh_scrollbar_visibility()

func refresh_scrollbar_visibility():
	if config_loader.get_data("settings", "show_scrollbar"):
		scroll_container.theme = load("res://maps/themes_and_styles/scroll.theme")
	else:
		scroll_container.theme = load("res://maps/themes_and_styles/scroll_remover.theme")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		$click.play()
		main_menu()

func _on_back_button_scrollincluded_pressed():
	main_menu()

func main_menu():
	communicator.animated_menu.change_to_menu(communicator.MAIN)
