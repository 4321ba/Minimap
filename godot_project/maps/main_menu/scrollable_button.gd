extends "res://maps/main_menu/button.gd"

signal scrollincluded_pressed

var pressdown_position = Vector2()
var press_threshold = 20

func _gui_input(event):
	if event is InputEventMouseButton and config_loader.get_data("settings", "input_method") == config_loader.TOUCHSCREEN and not disabled:
		if event.pressed:
			pressdown_position = event.position
		elif event.position.distance_to(pressdown_position) <= press_threshold:
			$click.play()
			call_deferred("emit_signal", "scrollincluded_pressed")

func _on_scrollable_button_pressed():
	if config_loader.get_data("settings", "input_method") != config_loader.TOUCHSCREEN:
		emit_signal("scrollincluded_pressed")
