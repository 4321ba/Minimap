extends "res://characters/enemy.gd"

var visible_enemies = []
var healables = []
var close_enemies = []
var is_player_close = false

func _process(delta):
	if goto_target != null and goto_target.is_dead:
		goto_path = PoolVector2Array()
	var most_hit_enemy = null
	var health_ratio = 1
	for enemy in visible_enemies:
		if float(enemy.health) / enemy.max_health < health_ratio and not enemy.is_dead:
			most_hit_enemy = enemy
			health_ratio = float(enemy.health) / enemy.max_health
	var prev_goto_target = goto_target
	goto_target = most_hit_enemy
	if goto_target != prev_goto_target:
		determine_ai_mode()

func attack():
	if can_move() and not is_in_attack_delay:
		for enemy in healables:
			enemy.take_damage(0, enemy_stun_time)
		start_hitting()

func determine_ai_mode():
	target_to_share = null
	if is_kiting:
		ai_mode = AI_KITE
		target_to_share = communicator.player
	elif goto_target in close_enemies:
		ai_mode = AI_ATTACK
	elif goto_target != null or (shared_target != null and not is_player_close) or goto_path.size() != 0:
		ai_mode = AI_GO_TO_TARGET
	else:
		idle_mode = null
		$idle_timer.start(rand_range(1, 2))
		ai_mode = AI_IDLE

func deal_damage():
	for enemy in healables:
		enemy.heal(strength)

func _on_view_distance_body_entered(body):
	if body.is_in_group("enemy") and body != self:
		visible_enemies.append(body)
		determine_ai_mode()

func _on_view_distance_body_exited(body):
	if body in visible_enemies:
		visible_enemies.erase(body)
		determine_ai_mode()

func _on_hit_distance_body_entered(body):
	if body.is_in_group("enemy") and body != self:
		healables.append(body)
	if body.is_in_group("player"):
		is_player_close = true
		goto_path = PoolVector2Array()
		determine_ai_mode()

func _on_hit_distance_body_exited(body):
	if body in healables:
		healables.erase(body)
	if body.is_in_group("player"):
		is_player_close = false
		determine_ai_mode()

func _on_attack_distance_body_entered(body):
	if body.is_in_group("enemy") and body != self:
		close_enemies.append(body)
		determine_ai_mode()

func _on_attack_distance_body_exited(body):
	if body in close_enemies:
		close_enemies.erase(body)
		determine_ai_mode()
