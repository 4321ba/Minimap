extends CanvasLayer

var is_finished = true

onready var tween = $tween
onready var fader = $fader

func _ready():
	call_deferred("_deferred_ready")

func _deferred_ready():
	fade(false)

func change_scene(path):
	if not is_finished:
		return
	is_finished = false
	fade(true)
	yield(tween, "tween_completed")
	get_tree().change_scene(path)
	get_tree().paused = false
	fade(false)
	yield(tween, "tween_completed")
	is_finished = true

func fade(is_fading_in):
	var from = config_loader.clear_color
	var to = Color(from.r, from.g, from.b, 0)
	if is_fading_in:
		var temp = from
		from = to
		to = temp
	tween.interpolate_property(fader, "color", from, to, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
