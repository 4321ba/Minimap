extends Node2D

var shared_target

func _ready():
	for enemy in get_children():
		enemy.is_in_swarm = true

func _process(delta):
	var found_target = false
	for enemy in get_children():
		if enemy.target_to_share != null and not enemy.is_dead:
			shared_target = enemy.target_to_share
			found_target = true
			break
	if not found_target:
		shared_target = null
	for enemy in get_children():
		if enemy.shared_target != shared_target:
			enemy.shared_target = shared_target
			enemy.determine_ai_mode()
