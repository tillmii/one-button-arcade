extends Control


const _GAMES_FOLDER_PATH: String = "res://games/"
const _PANEL_TEMPLATE_SCENE = preload("res://scenes/template.tscn")
const _DOT_SCENE = preload("res://scenes/dot.tscn")

@export var panel_indicator: HBoxContainer
@export var panels_hbox: HBoxContainer

var _current_panel_idx: int = 0
var _max_panel_idx: int

var tween

func _ready() -> void:
	# Update games folder (download missing games from git)
		# Test data for now
	
	# Init panel indicator
	initialize_panel_indicator()
	
	# Read all games
	var games_folder_dir = DirAccess.open(_GAMES_FOLDER_PATH)
	for directory in games_folder_dir.get_directories():
		
		# Create panel for each game
		var new_panel: PanelTemplate = _PANEL_TEMPLATE_SCENE.instantiate()
		new_panel.panel_is_active = false
		
		# Get panel info
		var new_read_me: String = FileAccess.open(str(_GAMES_FOLDER_PATH, "/", directory, "/", "README.md"), FileAccess.READ).get_as_text()
		var regex = RegEx.new()
		regex.compile("#\\s*(.*)\\n\\n(.*)")
		
		# Set panel info
		var new_panel_title: String = regex.search(new_read_me).get_string(1)
		var new_panel_description: String = regex.search(new_read_me).get_string(2)
		var new_panel_image_texture: Texture = load(str(_GAMES_FOLDER_PATH, "/", directory, "/", "image.jpg"))
		var new_panel_game_exe_path: String = str(_GAMES_FOLDER_PATH, "/", directory, "/", "game.exe")
		new_panel.initialize_panel(new_panel_title, new_panel_description, new_panel_image_texture, new_panel_game_exe_path)
		
		# Add panel
		panels_hbox.add_child(new_panel)
	
	panels_hbox.get_child(0).panel_is_active = true
	var first_panel_copy = panels_hbox.get_child(0).duplicate()
	panels_hbox.add_child(first_panel_copy)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			panels_hbox.get_child(_current_panel_idx).button_is_pressed = true
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			panels_hbox.get_child(_current_panel_idx).button_is_pressed = false
			next_panel()
			panel_indicator.get_child(_current_panel_idx).selected = false
			panels_hbox.get_child(_current_panel_idx).panel_is_active = false
			_current_panel_idx = (_current_panel_idx + 1) % _max_panel_idx
			panel_indicator.get_child(_current_panel_idx).selected = true
			panels_hbox.get_child(_current_panel_idx).panel_is_active = true
			
			if (_current_panel_idx == 0):
				await tween.finished
				panels_hbox.position.x = 0.0


func next_panel():
	tween = create_tween()
	tween.tween_property(panels_hbox, "position", Vector2(get_next_panel_position(), panels_hbox.position.y) , 0.5)


func get_next_panel_position():
	if !panels_hbox.position.x < (panels_hbox.get_child_count() - 2) * -1152.0:
		return panels_hbox.position.x - 1152.0
	return 0.0


func initialize_panel_indicator():
	var dir = DirAccess.open(_GAMES_FOLDER_PATH)
	_max_panel_idx = len(dir.get_directories())
	for i in range(_max_panel_idx):
		var new_dot = _DOT_SCENE.instantiate()
		panel_indicator.add_child(new_dot)
		panel_indicator.get_child(i).selected = false
	panel_indicator.get_child(0).selected = true
