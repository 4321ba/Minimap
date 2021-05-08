extends Control

onready var respec_button = $MarginContainer/VBoxContainer/HBoxContainer/respec_button
onready var usable_points = $MarginContainer/VBoxContainer/HBoxContainer/usable_points
onready var back_button = $MarginContainer/VBoxContainer/HBoxContainerBottom/back_button
onready var vbox = $MarginContainer/VBoxContainer
onready var bottom_hbox = $MarginContainer/VBoxContainer/HBoxContainerBottom
onready var difficulty_help = $MarginContainer/VBoxContainer/HBoxContainerBottom/difficulty_help

func _ready():
	back_button.grab_focus()
	if communicator.respecable_skill_points == 0:
		respec_button.visible = false
	usable_points.text = usable_points.text % config_loader.get_data("skill_points", "unassigned")
	var difficulty = config_loader.get_data("settings", "difficulty")
	difficulty_help.text = constanter.DIFFICULTY_DESCRIPTIONS[difficulty]
	difficulty_help.set("custom_colors/font_color", constanter.DIFFICULTY_COLORS[difficulty])
	var skill_row_scene = load("res://maps/main_menu/skill_row.tscn")
	for spec in constanter.BASE_PLAYER_SPECS:
		var skill_row = skill_row_scene.instance()
		skill_row.skill_name = spec
		vbox.add_child(skill_row)
	bottom_hbox.raise()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		$click.play()
		back()

func back():
	communicator.respecable_skill_points = 0
	communicator.animated_menu.change_to_menu(communicator.MAIN)

func _on_respec_button_pressed():
	for spec in constanter.BASE_PLAYER_SPECS:
		config_loader.set_data("skill_points", spec, 0)
	config_loader.set_data("skill_points", "unassigned", communicator.respecable_skill_points)
	yield(respec_button.get_node("click"), "finished")
	communicator.animated_menu.change_to_menu(communicator.SKILLS, false)

func _on_back_button_pressed():
	back()
