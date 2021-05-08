extends "res://characters/enemy.gd"

func _ready():
	use_light_attack_alert = false

func go_to_target():
	var target = goto_target if goto_target != null else shared_target
	rotation_target = target.global_position - global_position
	rotation_speed = walking_rotation_speed

func start_hitting():
	if not can_move() or is_in_attack_delay:
		return
	.start_hitting()
	$attack_alert_line.visible = true

func die():
	.die()
	$attack_alert_line.visible = false

func _on_attack_alert_timer_timeout():
	is_alerting_attack = false
	deal_damage()
	$attack_alert_line.visible = false
