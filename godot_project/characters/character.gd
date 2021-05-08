extends KinematicBody2D

export var attack_delay = 1.5
export var attack_alert_time = 0.5
export var strength = 5
export var enemy_stun_time = 0.6
export var max_health = 20
export var self_stun_multiplier = 1.0
export var speed = 100
export var walking_rotation_speed = 0.2 #amount of change in rotation in
export var turning_rotation_speed = 0.1 #1/60s from current to needed
export var light_animation_time = 0.1 #is in both ends part of attack alert time

onready var hpbar = $hpbar_holder/hpbar
onready var default_color = $polygon.color

var health = 0
var hittables = []
var is_dead = false
var is_stunned = false
var is_alerting_attack = false
var is_in_attack_delay = false

var use_light_attack_alert = true

var rotation_target = Vector2()
var rotation_speed = walking_rotation_speed

func _ready():
	health = max_health
	$particles/hit.color = default_color
	$particles/death.color = default_color
	hpbar.rect_rotation = -rotation_degrees

func _process(delta):
	if rotation_target == Vector2() or not can_move():
		return
	var needed_rotation = -rotation_target.angle_to(Vector2(0, -1))
	if rotation - needed_rotation > PI:
		needed_rotation += 2 * PI
	elif rotation - needed_rotation <= -PI:
		needed_rotation -= 2 * PI
	rotation = pow(1 - rotation_speed, delta * 60) * (rotation - needed_rotation) + needed_rotation
	hpbar.rect_rotation = -rotation_degrees

func start_hitting():
	if not can_move() or is_in_attack_delay:
		return
	$attack_delay_timer.start(attack_delay)
	is_in_attack_delay = true
	var alert_time = attack_alert_time - light_animation_time if use_light_attack_alert else attack_alert_time
	$attack_alert_timer.start(alert_time)
	is_alerting_attack = true
	if use_light_attack_alert:
		$attack_alert.enabled = true
		animate_attack_light(true)
	$audio/start_hitting.play()

func animate_attack_light(is_lighting_up):
	var from = 0 if is_lighting_up else 1
	var to = 1 if is_lighting_up else 0
	$tween.interpolate_property($attack_alert, "energy", from, to, light_animation_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$tween.start()

func deal_damage():
	if hittables.size() == 0:
		$audio/blank_hit.play()
	else:
		$audio/damage.play()
		communicator.player.shake_screen(strength, is_in_group("enemy"), enemy_stun_time / 2.0)
	for target in hittables:
		target.take_damage(strength, enemy_stun_time)

func heal(hp):
	if is_dead:
		return
	health += hp
	if health >= max_health:
		health = max_health
	update_hpbar()
	$particles/heal.emitting = true
	$audio/healing.play()

func take_damage(damage, stun_time):
	if is_dead:
		return
	health -= damage
	if health <= 0:
		die()
	else:
		$particles/hit.emitting = true
		update_hpbar()
	if $stun_timer.time_left < stun_time * self_stun_multiplier:
		$stun_timer.start(stun_time * self_stun_multiplier)
		is_stunned = true

func update_hpbar():
	$tween.interpolate_property(hpbar, "value", hpbar.value, float(health) / max_health, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$tween.start()

func die():
	health = 0
	$tween.remove_all()
	update_hpbar()
	is_dead = true
	$attack_alert_timer.stop()
	$attack_alert.enabled = false
	$audio/death.play()
	$death_timer.start()
	$polygon.color = default_color
	$animation_player.play("death")
	$collision_shape.queue_free()
	communicator.pause_menu.check_characters(false)

func can_move():
	if is_dead or is_stunned or is_alerting_attack:
		return false
	return true

func _on_hit_distance_body_entered(body):
	if body == self:
		return
	if is_in_group("enemy") and body.is_in_group("enemy"):
		return
	if not body.is_in_group("player") and not body.is_in_group("enemy"):
		return
	hittables.append(body)

func _on_hit_distance_body_exited(body):
	if body in hittables:
		hittables.erase(body)

func _on_attack_delay_timer_timeout():
	if not is_dead:
		$tween.interpolate_property($polygon, "color", Color(1, 1, 1), default_color, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$tween.start()
	is_in_attack_delay = false

func _on_attack_alert_timer_timeout():
	animate_attack_light(false)

func _on_stun_timer_timeout():
	is_stunned = false

func _on_death_timer_timeout():
	if is_in_group("player"):
		communicator.pause_menu.version = "restart"
		communicator.pause_menu.show()
	elif is_in_group("enemy"):
		queue_free()
		communicator.pause_menu.check_characters(true)

func _on_tween_tween_completed(object, key):
	if object == $attack_alert and key == ":energy" and $attack_alert.energy == 0:
		is_alerting_attack = false
		$attack_alert.enabled = false
		deal_damage()
	elif object == hpbar and key == ":value" and hpbar.value == 0:
		hpbar.queue_free()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		$particles/death.emitting = true
