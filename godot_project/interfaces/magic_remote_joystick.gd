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
	if (event is InputEventMouseButton or event is InputEventMouseMotion) and currently_pressing:
		move_joystick(event)


func _on_magic_remote_joystick_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		currently_pressing = true
		event.position += rect_global_position
		move_joystick(event)

func move_joystick(event):
	var input_position = event.position - center.rect_global_position
	var max_distance = 300
	if input_position.length() >= max_distance:
		input_position = input_position.normalized() * max_distance
	if event is InputEventMouseButton and not event.pressed:
		currently_pressing = false
		input_position = Vector2()
	communicator.joystick_position = input_position / max_distance
