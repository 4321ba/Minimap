extends Control

func _ready():
	if config_loader.get_data("settings", "show_pause_button"):
		visible = true
	else:
		queue_free()

func _on_pause_button_pressed():
	if config_loader.get_data("settings", "input_method") != config_loader.TOUCHSCREEN:
		communicator.pause_menu.toggle_pause()

func _on_touch_pause_button_pressed():
	if config_loader.get_data("settings", "input_method") == config_loader.TOUCHSCREEN:
		$pause_button/click.play()
		communicator.pause_menu.toggle_pause()
