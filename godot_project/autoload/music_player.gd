extends Node

enum {NONE, MENU, FIGHT_1, FIGHT_2_INTRO, FIGHT_2, FIGHT_3_INTRO, FIGHT_3, FIGHT_4_INTRO, FIGHT_4, LEVEL_COMPLETED, PLAYER_DEATH, FIGHT}
const NORMAL_FIGHT = [FIGHT_2_INTRO, FIGHT_3_INTRO, FIGHT_4_INTRO]
const BOSS_FIGHT = FIGHT_1
const FILENAMES = {
	NONE: "",
	MENU: "menu",
	FIGHT_1: "fight_1",
	FIGHT_2: "fight_2",
	FIGHT_2_INTRO: "fight_2_intro",
	FIGHT_3: "fight_3",
	FIGHT_3_INTRO: "fight_3_intro",
	FIGHT_4: "fight_4",
	FIGHT_4_INTRO: "fight_4_intro",
	LEVEL_COMPLETED: "level_completed",
	PLAYER_DEATH: "player_death",
}
var current_music_object
var previous_fight_music
var music_piece_scene = load("res://autoload/music_piece.tscn")

func _ready():
	randomize()

func play(music):
	if music == FIGHT:
		music = replace_fight_music()
	fade_out()
	var scene = music_piece_scene.instance()
	scene.piece_to_play = music
	current_music_object = scene
	add_child(scene)

func replace_fight_music():
	if communicator.pause_menu.is_boss_level:
		return BOSS_FIGHT
	var available_music = NORMAL_FIGHT.duplicate()
	available_music.erase(previous_fight_music)
	previous_fight_music = available_music[randi() % available_music.size()]
	return previous_fight_music

func fade_out():
	if current_music_object != null:
		current_music_object.fade_out()
		current_music_object = null

func piece_finished(object, music):
	if current_music_object != object:
		return
	current_music_object = null
	if music == FIGHT_2_INTRO:
		play(FIGHT_2)
	if music == FIGHT_3_INTRO:
		play(FIGHT_3)
	if music == FIGHT_4_INTRO:
		play(FIGHT_4)
