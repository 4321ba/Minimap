extends HBoxContainer

onready var skill_name_label = $skill_name_label
onready var plus_one_button = $plus_one_button
onready var difficulty_change = $difficulty_change
onready var skill_description = $skill_description
onready var current = $current
onready var next = $next

export var skill_name = "skill"

func _ready():
	skill_name_label.text = constanter.SPEC_DESCRIPTIONS[skill_name][0]
	skill_description.text = constanter.SPEC_DESCRIPTIONS[skill_name][1]
	var unit = constanter.SPEC_DESCRIPTIONS[skill_name][2]
	var current_number = stepify(constanter.get_player_spec(skill_name), 0.01)
	var next_number = stepify(constanter.get_player_spec(skill_name, 1), 0.01)
	if unit == "%":
		current_number *= 100
		next_number *= 100
	current.text = str(current_number) + unit
	next.text = str(next_number) + unit
	plus_one_button.text = str(config_loader.get_data("skill_points", skill_name))
	var difficulty_points = constanter.get_current_difficulty_modification(skill_name)
	if difficulty_points != 0:
		if difficulty_points > 0:
			difficulty_change.text = "+"
		difficulty_change.text += str(difficulty_points)
		difficulty_change.set("custom_colors/font_color", constanter.DIFFICULTY_COLORS[config_loader.get_data("settings", "difficulty")])
		difficulty_change.set("custom_colors/font_outline_modulate", Color.white)
	if config_loader.get_data("skill_points", "unassigned") <= 0:
		plus_one_button.disabled = true
		plus_one_button.focus_mode = FOCUS_NONE

func _on_plus_one_button_pressed():
	if config_loader.get_data("skill_points", "unassigned") > 0:
		config_loader.set_data("skill_points", skill_name, config_loader.get_data("skill_points", skill_name) + 1)
		config_loader.set_data("skill_points", "unassigned", config_loader.get_data("skill_points", "unassigned") - 1)
		yield(plus_one_button.get_node("click"), "finished")
		communicator.animated_menu.change_to_menu(communicator.SKILLS, false)
