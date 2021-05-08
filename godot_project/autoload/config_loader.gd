extends Node

const SAVE_PATH = "user://data.cfg"
var _config_file = ConfigFile.new()

enum {LIT, CHALLENGING, UNLIT}
enum {SHAKING, PLAYER_ONLY, NONSHAKING}
enum {DIFFICULTY_NONE = -1, EASY, MEDIUM, HARD}

var _data = {
	"settings": {
		"use_touch_input": false,
		"show_scrollbar": true,
		"music": 4,
		"sound_effects": 5,
		"animated_menu": true,
		"lighting": LIT,
		"screen_shaking": PLAYER_ONLY,
		"fullscreen": false,
		"show_pause_button": false,
		"vsync": true,
		"difficulty": EASY,
	},
	"skill_points": {
		"attack_delay": 0,
		"attack_alert_time": 0,
		"strength": 0,
		"enemy_stun_time": 0,
		"max_health": 0,
		"self_stun_multiplier": 0,
		"speed": 0,
		"unassigned": 0,
	},
	"misc": {
		"first_uncompleted_level": 1,
	},
	"level_difficulties_done": {
	} #populated in _ready() because it's for all the levels, and there are many of them
}

var levels = []
var clear_color

func _ready():
	scan_levels()
	for level in levels:
		_data["level_difficulties_done"][level] = DIFFICULTY_NONE
	load_settings()
	if OS.get_name() == "Android":
		if _config_file.get_value("settings", "use_touch_input") == null:
			set_data("settings", "use_touch_input", true)
		if _config_file.get_value("settings", "show_pause_button") == null:
			set_data("settings", "show_pause_button", true)
		if _config_file.get_value("settings", "lighting") == null:
			set_data("settings", "lighting", UNLIT)
	if OS.get_name() == "HTML5":
		if _config_file.get_value("settings", "show_pause_button") == null:
			set_data("settings", "show_pause_button", true)
	refresh_clear_color()
	refresh_fullscreen()
	refresh_vsync()
	refresh_audio("music")
	refresh_audio("sound_effects")
	pause_mode = Node.PAUSE_MODE_PROCESS

func _input(event):
	if not OS.get_name() == "Android" and not OS.get_name() == "HTML5" and event.is_action_pressed("ui_fullscreen"):
		config_loader.set_data("settings", "fullscreen", not config_loader.get_data("settings", "fullscreen"))
		refresh_fullscreen()
		if communicator.animated_menu != null and communicator.menu_to_display == communicator.OPTIONS:
			communicator.animated_menu.change_to_menu(communicator.OPTIONS, false)

func scan_levels():
	var dir = Directory.new()
	dir.open("res://maps/levels/")
	dir.list_dir_begin(true)
	while true:
		var filename = dir.get_next()
		if filename == "":
			break
		levels.append(filename.split(".")[0])
	levels.sort()

func refresh_clear_color():
	if config_loader.get_data("settings", "lighting") == CHALLENGING:
		clear_color = Color.black
	else:
		clear_color = Color(0.39, 0.12, 0.12)
	VisualServer.set_default_clear_color(clear_color)

func refresh_fullscreen():
	OS.set_window_fullscreen(config_loader.get_data("settings", "fullscreen"))

func refresh_vsync():
	OS.set_use_vsync(config_loader.get_data("settings", "vsync"))

func refresh_audio(bus):
		var bus_id = AudioServer.get_bus_index(bus)
		var setting = config_loader.get_data("settings", bus)
		AudioServer.set_bus_mute(bus_id, not bool(setting))
		AudioServer.set_bus_volume_db(bus_id, (setting - 5) * 5)

func get_data(section, key):
	return _data[section][key]

func set_data(section, key, value):
	_data[section][key] = value
	_config_file.set_value(section, key, value)
	_config_file.save(SAVE_PATH)

func load_settings():
	if not File.new().file_exists(SAVE_PATH):
		_config_file.save(SAVE_PATH)
		return
	var error = _config_file.load(SAVE_PATH)
	if error != OK:
		print("Error loading game data: error " + str(error))
		return
	for section in _data:
		for key in _data[section]:
			_data[section][key] = _config_file.get_value(section, key, _data[section][key])
