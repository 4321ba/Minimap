extends Node

const CAN_CHEAT = true
var is_currently_cheating = false

var joystick_position = Vector2()
var respecable_skill_points = 0 #0 if can't respec

enum {MAIN, LEVELS, SKILLS, OPTIONS, HELP}
var menu_to_display = MAIN

var player
var ground
var pause_menu
var animated_menu
var options_and_levels

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		var escape_event = InputEventKey.new()
		escape_event.scancode = KEY_ESCAPE
		escape_event.pressed = true
		get_tree().input_event(escape_event)
