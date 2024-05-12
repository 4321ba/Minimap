extends Control

onready var center = $center

var currently_pressing = false

func _ready():
	if config_loader.get_data("settings", "input_method") == config_loader.MAGIC_REMOTE:
		visible = true
		communicator.joystick_position = Vector2()
	else:
		queue_free()


func _input(event):
	if (event is InputEventMouseButton or event is InputEventMouseMotion):
		move_joystick(event)


func _on_magic_remote_joystick_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		event.position += rect_global_position
		move_joystick(event)

func move_joystick(event):
	var input_position = event.position - center.rect_global_position
	var max_distance = 300
	var min_distance = 150
	if input_position.length() <= min_distance and input_position.length() >= 1:
		input_position = input_position.normalized()
	if input_position.length() >= max_distance:
		input_position = input_position.normalized() * max_distance
	
	if input_position.length() <= 1.1:
		communicator.joystick_position = input_position / 1000
	else:
		communicator.joystick_position = (input_position - input_position.normalized() * min_distance) / (max_distance - min_distance)
