extends "res://maps/main_menu/button.gd"

signal scrollincluded_pressed

var pressdown_position = Vector2()
var press_threshold = 20

func _gui_input(event):
	if event is InputEventMouseButton and config_loader.get_data("settings", "use_touch_input") and not disabled:
		if event.pressed:
			pressdown_position = event.position
		elif event.position.distance_to(pressdown_position) <= press_threshold:
			$click.play()
			call_deferred("emit_signal", "scrollincluded_pressed")

func _on_scrollable_button_pressed():
	if not config_loader.get_data("settings", "use_touch_input"):
		emit_signal("scrollincluded_pressed")
