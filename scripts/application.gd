class_name Application
extends Control


# signals
signal button_pressed
signal button_released
signal set_active_panel(active_panel: GamePanel)
signal set_active_dot(active_dot: Dot)

# paths and scenes
const _GAMES_FOLDER_PATH: String = "res://games/"
const _PANEL_TEMPLATE_SCENE = preload("res://scenes/game_panel.tscn")
const _DOT_SCENE = preload("res://scenes/dot.tscn")

# exports
@export var panel_indicator: HBoxContainer
@export var panels_hbox: HBoxContainer

# variables
var _current_panel_idx: int = 0
var _max_panel_idx: int


func _ready() -> void:
	# update games folder (download missing games from git)
		# test data for now
	
	# inits
	initialize_panel_indicator()
	
	# read all games
	var games_folder_dir = DirAccess.open(_GAMES_FOLDER_PATH)
	for directory in games_folder_dir.get_directories():
		
		# create panel for each game
		var new_panel: GamePanel = _PANEL_TEMPLATE_SCENE.instantiate()
		new_panel.panel_is_active = false
		
		# get panel info from "README.md"
		var new_read_me: String = FileAccess.open(str(_GAMES_FOLDER_PATH, "/", directory, "/", "README.md"), FileAccess.READ).get_as_text()
		var regex = RegEx.new()
		regex.compile("#\\s*(.*)\\n\\n(.*)")
		
		# set panel info
		var new_panel_title: String = regex.search(new_read_me).get_string(1)
		var new_panel_description: String = regex.search(new_read_me).get_string(2)
		var new_panel_image_texture: Texture = load(str(_GAMES_FOLDER_PATH, "/", directory, "/", "image.jpg"))
		var new_panel_game_exe_path: String = str(_GAMES_FOLDER_PATH, "/", directory, "/", "game.exe")
		new_panel.initialize_panel(new_panel_title, new_panel_description, new_panel_image_texture, new_panel_game_exe_path)
		
		# add panel
		panels_hbox.add_child(new_panel)
	panels_hbox.get_child(0).panel_is_active = true
	
	# add a copy of panel 0 to allow animation from last game to first game
	var first_panel_copy = panels_hbox.get_child(0).duplicate()
	panels_hbox.add_child(first_panel_copy)
	
	# react to button
	connect("button_released", next_panel)


func initialize_panel_indicator():
	var dir = DirAccess.open(_GAMES_FOLDER_PATH)
	_max_panel_idx = len(dir.get_directories())
	for i in range(_max_panel_idx):
		var new_dot = _DOT_SCENE.instantiate()
		panel_indicator.add_child(new_dot)
	set_active_dot.emit(panel_indicator.get_child(0))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			button_pressed.emit()
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			button_released.emit()


func next_panel():
	
	# increase panel index
	_current_panel_idx = (_current_panel_idx + 1) % _max_panel_idx
	
	# set new panel and dot
	set_active_panel.emit(panels_hbox.get_child(_current_panel_idx))
	set_active_dot.emit(panel_indicator.get_child(_current_panel_idx))
	
	# tween
	var tween = create_tween()
	tween.tween_property(panels_hbox, "position", Vector2(get_next_panel_position(), panels_hbox.position.y) , 0.5)
	
	# reset position when last game is reached
	if (_current_panel_idx == 0):
		await tween.finished
		panels_hbox.position.x = 0.0


func get_next_panel_position():
	if !panels_hbox.position.x < (panels_hbox.get_child_count() - 2) * -1152.0:
		return panels_hbox.position.x - 1152.0
	return 0.0
