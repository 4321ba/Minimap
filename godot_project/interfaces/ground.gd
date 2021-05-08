extends Navigation2D

func _ready():
	communicator.ground = self
	refresh_tiles()

func refresh_tiles():
	if config_loader.get_data("settings", "lighting") == config_loader.LIT:
		$tilemap.tile_set = load("res://interfaces/tileset_darker.tres")
	else:
		$tilemap.tile_set = load("res://interfaces/tileset_lighter.tres")
