extends Control

var version = "pause"

onready var level_completed_label = $MarginContainer/VBoxContainer/level_completed_label
onready var resume_button = $MarginContainer/VBoxContainer/resume_button
onready var next_level_button = $MarginContainer/VBoxContainer/next_level_button
onready var restart_button = $MarginContainer/VBoxContainer/restart_button
onready var skills_button = $MarginContainer/VBoxContainer/skills_button
onready var tween = $tween
onready var fader = $fader
onready var buttons = $MarginContainer

var next_level_filename = "res://maps/levels/%s.tscn"
onready var current_filename = get_tree().get_current_scene().filename
onready var current_level_str = current_filename.split("/")[-1].split(".")[0]
onready var current_level_id = int(current_level_str)
onready var is_boss_level = current_level_id % 9 == 0

func _ready():
	communicator.pause_menu = self
	visible = false
	if config_loader.get_data("settings", "input_method") == config_loader.KEYBOARD:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var str_next_id = str(current_level_id + 1)
	if str_next_id.length() == 1:
		str_next_id = "0" + str_next_id
	if str_next_id.length() == 2:
		str_next_id = "0" + str_next_id
	next_level_filename = next_level_filename % str_next_id

func _input(event):
	if event.is_action_pressed("ui_reload"):
		$click.play()
		reload()
	if event.is_action_pressed("ui_cancel"):
		$click.play()
		toggle_pause()

func show():
	match version:
		"pause":
			next_level_button.visible = false
			skills_button.visible = false
			resume_button.visible = true
			level_completed_label.visible = false
			resume_button.grab_focus()
		"restart":
			next_level_button.visible = false
			skills_button.visible = false
			resume_button.visible = false
			level_completed_label.text = "You died!"
			level_completed_label.visible = true
			restart_button.grab_focus()
			music_player.play(music_player.PLAYER_DEATH)
		"next_level":
			next_level_button.visible = true
			resume_button.visible = false
			level_completed_label.text = level_completed_label.text % current_level_id
			level_completed_label.visible = true
			if is_boss_level:
				skills_button.visible = true
				update_unassigned_skill_points(current_level_id / 9)
				skills_button.grab_focus()
			else:
				skills_button.visible = false
				next_level_button.grab_focus()
			if config_loader.get_data("misc", "first_uncompleted_level") == current_level_id:
				config_loader.set_data("misc", "first_uncompleted_level", current_level_id + 1)
			var difficulty = config_loader.get_data("settings", "difficulty")
			if config_loader.get_data("level_difficulties_done", current_level_str) < difficulty:
				config_loader.set_data("level_difficulties_done", current_level_str, difficulty)
			if not File.new().file_exists(next_level_filename):
				next_level_button.disabled = true
				next_level_button.focus_mode = FOCUS_NONE
			music_player.play(music_player.LEVEL_COMPLETED)
	get_tree().paused = true
	fade(true)
	buttons.visible = true
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func resume():
	get_tree().paused = false
	fade(false)
	buttons.visible = false
	if config_loader.get_data("settings", "input_method") == config_loader.KEYBOARD:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	yield(get_tree().create_timer(tween.get_runtime()), "timeout")
	if not tween.is_active():
		visible = false

func fade(is_fading_in):
	var from = Color(0, 0, 0, 0) if is_fading_in else Color(0, 0, 0, 0.5)
	var to = Color(0, 0, 0, 0.5) if is_fading_in else Color(0, 0, 0, 0)
	tween.interpolate_property(fader, "color", from, to, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func toggle_pause():
	if version != "pause":
		return
	if get_tree().paused:
		resume()
	else:
		show()

func reload():
	scene_transitioner.change_scene(current_filename)

func check_characters(check_version): #check_version==true: when queueing free, false when just died
	if communicator.player.is_dead:
		if not check_version:
			yield(get_tree().create_timer(2), "timeout")
			music_player.fade_out()
		return
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if (check_version and not enemy.is_queued_for_deletion()) or (not check_version and not enemy.is_dead):
			return
	if check_version:
		version = "next_level"
		show()
	else:
		yield(get_tree().create_timer(2), "timeout")
		music_player.fade_out()

func update_unassigned_skill_points(max_points):
	var skill_points_sum = 0
	for spec in constanter.BASE_PLAYER_SPECS:
		skill_points_sum += config_loader.get_data("skill_points", spec)
	if max_points > skill_points_sum + config_loader.get_data("skill_points", "unassigned"):
		config_loader.set_data("skill_points", "unassigned", max_points - skill_points_sum)

func _on_resume_button_pressed():
	resume()

func _on_restart_button_pressed():
	reload()

func _on_quit_to_menu_button_pressed():
	communicator.menu_to_display = communicator.MAIN
	scene_transitioner.change_scene("res://maps/main_menu/animated_menu.tscn")

func _on_select_level_button_pressed():
	communicator.menu_to_display = communicator.LEVELS
	scene_transitioner.change_scene("res://maps/main_menu/animated_menu.tscn")

func _on_next_level_button_pressed():
	scene_transitioner.change_scene(next_level_filename)

func _on_skills_button_pressed():
	communicator.respecable_skill_points = current_level_id / 9
	communicator.menu_to_display = communicator.SKILLS
	scene_transitioner.change_scene("res://maps/main_menu/animated_menu.tscn")
