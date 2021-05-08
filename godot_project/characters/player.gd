extends "res://characters/character.gd"

var amplitude = 0
var single_shake_time = 0

func _ready():
	randomize()
	communicator.player = self
	add_to_group("player")
	for spec in constanter.BASE_PLAYER_SPECS:
		set(spec, constanter.get_player_spec(spec))
	health = max_health
	match config_loader.get_data("settings", "lighting"):
		config_loader.LIT:
			$background_light.energy = 0.6
		config_loader.CHALLENGING:
			$background_light.energy = 1
			$background_light.mode = Light2D.MODE_MASK
		config_loader.UNLIT:
			$background_light.queue_free()

func _process(delta):
	if not can_move():
		return
	var direction = Vector2()
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	direction = direction.normalized()
	if communicator.joystick_position != Vector2():
		direction = communicator.joystick_position
	move_and_slide(direction * speed)
	rotation_target = direction
	if Input.is_action_pressed("ui_select"):
		start_hitting()

func shake_screen(amplitude, is_player, duration, single_shake_time = 0.05):
	if config_loader.get_data("settings", "screen_shaking") == config_loader.NONSHAKING:
		return
	if config_loader.get_data("settings", "screen_shaking") == config_loader.PLAYER_ONLY and not is_player:
		return
	if $shake_timer.time_left > 0:
		if duration > $shake_timer.time_left:
			$shake_tween.remove_all()
		else:
			return
	self.amplitude = amplitude
	self.single_shake_time = single_shake_time
	$shake_timer.start(duration)
	one_shake(false)

func one_shake(shake_back):
	var shake_offset = Vector2()
	if not shake_back:
		var rad = rand_range(-PI, PI)
		shake_offset = Vector2(cos(rad), sin(rad)) * amplitude * $shake_timer.time_left / $shake_timer.wait_time
	$shake_tween.interpolate_property($camera, "offset", $camera.offset, shake_offset, single_shake_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$shake_tween.start()

func _on_shake_timer_timeout():
	one_shake(true)

func _on_shake_tween_tween_completed(object, key):
	if $shake_timer.time_left > 0:
		one_shake(false)
