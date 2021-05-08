extends AudioStreamPlayer

var piece_to_play = music_player.NONE
var path = "res://sounds/music/%s.ogg"

onready var tween = $tween

func _ready():
	stream = load(path % music_player.FILENAMES[piece_to_play])
	play()

func fade_out():
	tween.interpolate_property(self, "volume_db", 0, -60, 3)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()

func _on_music_piece_finished():
	music_player.piece_finished(self, piece_to_play)
	queue_free()
