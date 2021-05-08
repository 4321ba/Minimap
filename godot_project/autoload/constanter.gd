extends Node

const VERSION = "minimap_v1.0.0_development"
const BASE_PLAYER_SPECS = {
	"attack_delay": 1.5,
	"attack_alert_time": 0.5,
	"strength": 6,
	"enemy_stun_time": 0.6,
	"max_health": 40,
	"self_stun_multiplier": 1.0,
	"speed": 150,
}
enum {ADD, MULTIPLY}
const PLAYER_SPECS_MODIFIER = {
	"attack_delay": [MULTIPLY, 0.8],
	"attack_alert_time": [MULTIPLY, 0.8],
	"strength": [ADD, 1],
	"enemy_stun_time": [ADD, 0.2],
	"max_health": [ADD, 6],
	"self_stun_multiplier": [MULTIPLY, 0.8],
	"speed": [ADD, 10],
}
const DIFFICULTY_MODIFICATIONS = {
	config_loader.EASY: {"self_stun_multiplier": 2, "speed": 3},
	config_loader.MEDIUM: {},
	config_loader.HARD: {"max_health": -3, "strength": -2},
}
const DIFFICULTY_DESCRIPTIONS = {
	config_loader.EASY: "If you find Easy too easy, try Medium difficulty in Options.",
	config_loader.MEDIUM: "You might be tempted to try out Hard, but trust me, Medium is hard enough.",
	config_loader.HARD: "BEWARE! You're in Hard difficulty and you'll probably die. A lot.",
}
const SPEC_DESCRIPTIONS = {
	"attack_delay": ["Attack Delay", "The time you wait between two of your attacks, this includes Attack Time too.", "s"],
	"attack_alert_time": ["Attack Time", "Your attack takes this long. You can't move while you attack.", "s"],
	"strength": ["Strength", "The damage you deal to enemies.", "hp"],
	"enemy_stun_time": ["Stun Time", "The time while the enemies are immobile after your successful hit.", "s"],
	"max_health": ["Health", "The amount of damage you can take without dying.", "hp"],
	"self_stun_multiplier": ["Stunnability", "You can recover from a hit this fast. Your resistance to the Stun Time of the enemies.", "%"],
	"speed": ["Speed", "The amount of pixels you can move in a second if you're using a 720p window.", ""],
}
const OPTION_CATEGORIES = {
	"gameplay": ["difficulty"],
	"interface": ["use_touch_input", "animated_menu", "show_scrollbar", "show_pause_button"],
	"graphics": ["lighting", "screen_shaking", "fullscreen", "vsync"],
	"sounds": ["music", "sound_effects"],
}
const CATEGORY_TEXTS = {
	"gameplay": "Gameplay",
	"interface": "Interface",
	"graphics": "Graphics",
	"sounds": "Sounds",
}
const OPTION_TEXTS = {
	"use_touch_input": ["Input: Keyboard", "Input: Touchscreen"],
	"show_scrollbar": ["Scrollbar: Hidden", "Scrollbar: Shown"],
	"music": ["Music: Off", "Music: 20%", "Music: 40%", "Music: 60%", "Music: 80%", "Music: 100%"],
	"sound_effects": ["Sound effects: Off", "Sound effects: 20%", "Sound effects: 40%", "Sound effects: 60%", "Sound effects: 80%", "Sound effects: 100%"],
	"animated_menu": ["Menu background: Static", "Menu background: Animated"],
	"lighting": ["Lighting: Lit", "Lighting: Challenging", "Lighting: Unlit"],
	"screen_shaking": ["Screen shaking: All", "Screen shaking: Player only", "Screen shaking: Off"],
	"fullscreen": ["Fullscreen: Off", "Fullscreen: On"],
	"show_pause_button": ["Pause button: Hidden", "Pause button: Shown"],
	"vsync": ["VSync: Off", "VSync: On"],
	"difficulty": ["Difficulty: Easy", "Difficulty: Medium", "Difficulty: Hard"],
}
var help = {
	"Controls": "PC: move with WASD or arrows and hit with Space. Go back or pause with Escape or 0 (zero). On web with fullscreen use 0 instead of Escape to not escape from fullscreen.\n\nMobile: move with the joystick and hit with tapping the bottom right of the screen. The pause button has a bigger hitbox than it seems. Escape with the phone back button, if you have one. If you're on the web, set the Use touch input option.",
	"Combat": "When you start hitting, you become immobile for a little bit, and when you finish your attack, the enemies in your reach take damage and become immobile. Same applies for enemies: they can't move while they attack, but they stun you if you get hit.",
	"Levels": "Every ninth level is a boss level with light red name in the level select screen, and you get new content (e.g. new enemies) in the next level. You can complete a level in the 3 difficulty levels (Easy, Medium, Hard), and the highest one you completed the level in will be stored: you can see it from the color of the level buttons.",
	"Skill points": "You get skill points after defeating boss levels, capped at the number of the boss level (e.g. after defeating the third boss you get 3 points overall counting the already assigned ones). You can respec only after directly defeating a boss level and you get as much skill points as the number of the boss level. To unlock a new level you have to defeat every enemy in the previous level, in any difficulty.",
	"Difficulty": "The difficulty setting affects your skills: you move a bit faster (Speed) and can recover from a hit faster (Stunnability) if you're playing in Easy compared to playing in Medium, but you have less Health points and Strength when you're playing in Hard compared to playing in Medium.\nYour assigned skill points remain the same across difficulties. The color of the level button depends on the highest difficulty you completed the level on. If you unlock a level, you unlock it for every difficulty.",
	"Lighting bugs": "While using the Challenging option, some random lights don't show, it's an engine bug, not a feature.\nOn Android, using the Lit and Challenging option results in jagged edges if your phone doesn't support high precision calculations, but it may be slow otherwise too. Use Unlit if something wrong.",
	"Cheating": "Don't cheat :D. But if you're stuck at a level, or you just want to try the levels without beating the previous ones, you can press the Show scrollbar option at least 10 times and then go to the last level you want to be unlocked via the level select screen. You can lock levels the same way too.",
	"About": "Running %s with Godot %s on %s using the %s graphics API. Made by 1234ab." % [VERSION, Engine.get_version_info()["string"], OS.get_name(), ["GLES3", "GLES2"][OS.get_current_video_driver()]]
}
const DIFFICULTY_BUTTON_PATHS = {
	config_loader.EASY: "res://maps/themes_and_styles/button_easy.theme",
	config_loader.MEDIUM: "res://maps/themes_and_styles/button_medium.theme",
	config_loader.HARD: "res://maps/themes_and_styles/button_hard.theme",
}
const DIFFICULTY_COLORS = {
	config_loader.EASY: Color(0.84, 0.61, 0),
	config_loader.MEDIUM: Color(0.84, 0.31, 0),
	config_loader.HARD: Color(0.5, 0, 0.11),
}

func get_current_difficulty_modification(key):
	var difficulty_settings = DIFFICULTY_MODIFICATIONS[config_loader.get_data("settings", "difficulty")]
	return difficulty_settings[key] if key in difficulty_settings else 0

func get_player_spec(key, additional_points = 0):
	var points = config_loader.get_data("skill_points", key) + get_current_difficulty_modification(key) + additional_points
	if PLAYER_SPECS_MODIFIER[key][0] == ADD:
		return BASE_PLAYER_SPECS[key] + PLAYER_SPECS_MODIFIER[key][1] * points
	elif PLAYER_SPECS_MODIFIER[key][0] == MULTIPLY:
		return BASE_PLAYER_SPECS[key] * pow(PLAYER_SPECS_MODIFIER[key][1], points)
