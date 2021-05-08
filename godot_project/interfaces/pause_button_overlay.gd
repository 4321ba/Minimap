extends Control

func _ready():
	if config_loader.get_data("settings", "show_pause_button"):
		visible = true
	else:
		queue_free()

func _on_pause_button_pressed():
	if not config_loader.get_data("settings", "use_touch_input"):
		communicator.pause_menu.toggle_pause()

func _on_touch_pause_button_pressed():
	if config_loader.get_data("settings", "use_touch_input"):
		$pause_button/click.play()
		communicator.pause_menu.toggle_pause()
