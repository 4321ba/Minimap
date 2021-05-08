extends "res://characters/character.gd"

export var idle_distance = 150 # px
export var swarm_idle_distance = 300 # px
export var can_kite = false

var current_delta = 0
var target_to_share

enum {AI_IDLE, AI_GO_TO_TARGET, AI_ATTACK, AI_KITE}
var ai_mode = AI_IDLE
enum {IDLE_MOVE, IDLE_ROTATE}
var idle_mode
var idle_rotation_target
var idle_path = PoolVector2Array()

var goto_target
var shared_target
var goto_path = PoolVector2Array()
var attack_target

var is_in_swarm = false
var is_kiting = false
var on_screen = false
var notice_sound_played = false
var pathfinding_limiter = 0

func _ready():
	randomize()
	add_to_group("enemy")
	call_deferred("_deferred_ready")

func _deferred_ready():
	determine_ai_mode()

func _process(delta):
	current_delta = delta
	if can_kite and communicator.player != null:
		var prev_is_kiting = is_kiting
		if not communicator.player.is_alerting_attack:
			is_kiting = false
		elif self in communicator.player.hittables:
			is_kiting = true
		if prev_is_kiting != is_kiting:
			determine_ai_mode()
	match_ai_mode()

func match_ai_mode():
	match ai_mode:
		AI_IDLE:
			if on_screen:
				idle()
		AI_GO_TO_TARGET:
			go_to_target()
		AI_ATTACK:
			attack()
		AI_KITE:
			kite()

func new_target():
	if randf() < 0.7:
		idle_mode = IDLE_MOVE
		var target = Vector2(rand_range(-1, 1), rand_range(-1, 1))
		if is_in_swarm:
			target = target * swarm_idle_distance + get_parent().global_position
		else:
			target = target * idle_distance + global_position
		idle_path = get_path_to_point(target)
		$idle_timer.start(rand_range(3, 6))
	else:
		idle_mode = IDLE_ROTATE
		var rotation_rad = randf() * 2 * PI
		idle_rotation_target = Vector2(cos(rotation_rad), sin(rotation_rad))
		$idle_timer.start(rand_range(1, 3))

func idle():
	match idle_mode:
		IDLE_MOVE:
			idle_path = go_along_path(idle_path)
		IDLE_ROTATE:
			rotation_target = idle_rotation_target
			rotation_speed = turning_rotation_speed

func go_to_target():
	if pathfinding_limiter <= 0:
		pathfinding_limiter = 6
		if goto_target != null:
			goto_path = get_path_to_point(goto_target.global_position)
		elif shared_target != null:
			goto_path = get_path_to_point(shared_target.global_position)
	pathfinding_limiter -= 1
	goto_path = go_along_path(goto_path)

func attack():
	if attack_target == goto_target or attack_target == shared_target:
		rotation_target = attack_target.global_position - global_position
		rotation_speed = turning_rotation_speed
		start_hitting()

func kite():
	if not can_move():
		return
	var direction = communicator.player.global_position.direction_to(global_position)
	move_and_slide(direction * speed)
	rotation_target = direction
	rotation_speed = walking_rotation_speed

func get_path_to_point(point):
	return communicator.ground.get_simple_path(global_position, point)

func go_along_path(path):
	if not can_move():
		return path
	var distance = speed * current_delta
	var start_point = global_position
	for index in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if 0 <= distance and distance <= distance_to_next:
			move_and_slide(start_point.direction_to(path[0]) * speed)
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
	if path.size() != 0:
		rotation_target = path[0] - global_position
		rotation_speed = walking_rotation_speed
	else:
		if $idle_timer.is_stopped():
			determine_ai_mode()
	return path

func determine_ai_mode():
	if is_kiting:
		ai_mode = AI_KITE
	elif attack_target != null:
		ai_mode = AI_ATTACK
	elif goto_target != null or shared_target != null or goto_path.size() != 0:
		ai_mode = AI_GO_TO_TARGET
	else:
		idle_mode = null
		notice_sound_played = false
		$idle_timer.start(rand_range(1, 3))
		ai_mode = AI_IDLE

func _on_view_distance_body_entered(body):
	if body.is_in_group("player"):
		goto_target = body
		target_to_share = body
		determine_ai_mode()
		if shared_target == null and not notice_sound_played:
			notice_sound_played = true
			$audio/notice.play()
			var music = music_player.current_music_object
			if music == null or music.piece_to_play == music_player.PLAYER_DEATH or music.piece_to_play == music_player.LEVEL_COMPLETED:
				music_player.play(music_player.FIGHT)

func _on_view_distance_body_exited(body):
	if body == goto_target:
		goto_target = null
		target_to_share = null
		determine_ai_mode()

func _on_attack_distance_body_entered(body):
	if body.is_in_group("player"):
		attack_target = body
		determine_ai_mode()

func _on_attack_distance_body_exited(body):
	if body == attack_target:
		attack_target = null
		determine_ai_mode()

func _on_idle_timer_timeout():
	if ai_mode == AI_IDLE:
		new_target()

func _on_VisibilityNotifier2D_screen_entered():
	on_screen = true

func _on_VisibilityNotifier2D_screen_exited():
	on_screen = false
