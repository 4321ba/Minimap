extends Control

onready var hit_button = $splitter/right/hit_aligner/hit_button

func _ready():
	if config_loader.get_data("settings", "input_method") == config_loader.TOUCHSCREEN:
		visible = true
	else:
		queue_free()

func _process(delta):
	if hit_button.is_pressed():
		communicator.player.start_hitting()
