extends Control


const _GAMES_FOLDER_PATH: String = "res://games/"
const _PANEL_TEMPLATE_SCENE = preload("res://scenes/template.tscn")
const _DOT_SCENE = preload("res://scenes/dot.tscn")

@export var panel_indicator: HBoxContainer

var _current_panel_idx: int = 0
var _max_panel_idx: int = 10


func _ready() -> void:
	# Update games folder (download missing games from git)
	# test data for now
	
	# Init panel indicator
	initialize_panel_indicator()
	
	# Read all games
	var games_folder_dir = DirAccess.open(_GAMES_FOLDER_PATH)
	for directory in games_folder_dir.get_directories():
		# Create panel for each game
		var new_panel: PanelTemplate = _PANEL_TEMPLATE_SCENE.instantiate()
		# Get panel info
		var new_panel_title: String = ""
		var new_panel_description: String = ""
		var new_panel_image_texture: Texture
		# Set panel info
		new_panel.initialize_panel(new_panel_title, new_panel_description, new_panel_image_texture)
	
	pass


func initialize_panel_indicator():
	var dir = DirAccess.open(_GAMES_FOLDER_PATH)
	_max_panel_idx = len(dir.get_directories())
	for i in range(_max_panel_idx):
		var new_dot = _DOT_SCENE.instantiate()
		panel_indicator.add_child(new_dot)
	panel_indicator.get_child(0).selected = true
