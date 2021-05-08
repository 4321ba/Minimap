extends VBoxContainer

var title
var description

func _ready():
	$title.text = title
	$description.text = description
