tool
extends Control

export(int) var big_detail = 40
export(int) var big_radius = 100
export(int) var small_detail = 20
export(int) var small_radius = 20
export(bool) var update_polygons = false setget set_update_polygons

onready var big_circle = $big_circle
onready var small_circle = $big_circle/small_circle

var current_touch_index = -1

func _ready():
	update_polygons()
	if not Engine.is_editor_hint():
		communicator.joystick_position = Vector2()
		small_circle.color = config_loader.clear_color

func _input(event):
	if (event is InputEventScreenTouch or event is InputEventScreenDrag) and event.index == current_touch_index:
		move_joystick(event)

func set_update_polygons(value):
	update_polygons()

func update_polygons():
	big_circle.polygon = create_circle_coordinates(big_detail, big_radius)
	small_circle.polygon = create_circle_coordinates(small_detail, small_radius)

func create_circle_coordinates(resolution, radius):
	var coordinates = PoolVector2Array()
	for index in range(resolution):
		var angle_part = index * 2 * PI / resolution
		coordinates.append(Vector2(cos(angle_part) * radius, sin(angle_part) * radius))
	return coordinates

func _on_joystick_gui_input(event):
	if event is InputEventScreenTouch and event.pressed:
		current_touch_index = event.index
		event.position += rect_global_position
		move_joystick(event)

func move_joystick(event):
	var input_position = event.position - big_circle.global_position
	var max_distance = big_radius - small_radius
	if input_position.length() >= max_distance:
		input_position = input_position.normalized() * max_distance
	if event is InputEventScreenTouch and not event.pressed:
		current_touch_index = -1
		input_position = Vector2()
	small_circle.position = input_position
	communicator.joystick_position = input_position / max_distance
