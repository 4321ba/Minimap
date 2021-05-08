extends Node2D

const MENU_LOCATIONS = {
	communicator.MAIN: "res://maps/main_menu/main_menu.tscn",
	communicator.LEVELS: "res://maps/main_menu/levels.tscn",
	communicator.SKILLS: "res://maps/main_menu/skills.tscn",
	communicator.OPTIONS: "res://maps/main_menu/options.tscn",
	communicator.HELP: "res://maps/main_menu/help.tscn",
}
onready var menu_layer = $menu_layer
onready var ground = $ground
onready var background_light = $ground/background_light
onready var tween = $menu_layer/menu_transitioner/tween
onready var fader = $menu_layer/menu_transitioner/fader

var is_finished = true

func _ready():
	communicator.animated_menu = self
	change_to_menu(communicator.menu_to_display, false)
	refresh_animation_state()
	refresh_light_state()
	music_player.play(music_player.MENU)

func refresh_animation_state():
	ground.visible = config_loader.get_data("settings", "animated_menu")

func refresh_light_state():
	match config_loader.get_data("settings", "lighting"):
		config_loader.LIT:
			background_light.energy = 0.6
			background_light.mode = Light2D.MODE_ADD
		config_loader.CHALLENGING:
			background_light.energy = 1
			background_light.mode = Light2D.MODE_MASK
		config_loader.UNLIT:
			background_light.energy = 0
			background_light.mode = Light2D.MODE_ADD

func change_to_menu(menu, animate = true):
	if not is_finished:
		return
	is_finished = false
	if animate:
		fade(true)
		yield(tween, "tween_completed")
	for child in menu_layer.get_children():
		if child != $menu_layer/menu_transitioner:
			child.queue_free()
	menu_layer.add_child(load(MENU_LOCATIONS[menu]).instance())
	if animate:
		fade(false)
		yield(tween, "tween_completed")
	is_finished = true
	communicator.menu_to_display = menu

func fade(is_fading_in):
	var from = Color.white if is_fading_in else Color.transparent
	var to = Color.transparent if is_fading_in else Color.white
	tween.interpolate_property(fader, "color", from, to, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
