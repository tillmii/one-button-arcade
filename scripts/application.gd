extends Control


# signals
signal button_pressed
signal button_released
signal set_active_panel(active_panel: GamePanel)
signal set_active_dot(active_dot: Dot)

# paths and scenes
const _GAMES_FOLDER_PATH: String = "user://one-button-games/"
const _PANEL_TEMPLATE_SCENE = preload("res://scenes/game_panel.tscn")
const _DOT_SCENE = preload("res://scenes/dot.tscn")

# exports
@export var panel_indicator: HBoxContainer
@export var panels_hbox: HBoxContainer

# variables
var _current_panel_idx: int = 0
var _max_panel_idx: int


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().set_auto_accept_quit(false)
	
	await get_tree().process_frame
	
	initialize_panel_indicator()
	
	# read all games
	var games_folder_dir = DirAccess.open(_GAMES_FOLDER_PATH)
	for directory in games_folder_dir.get_directories():
		
		# create panel for each game
		var panel: GamePanel = _PANEL_TEMPLATE_SCENE.instantiate()
		panel.panel_is_active = false
		
		# set all data paths
		var read_me_path = "%s/%s/README.md" % [_GAMES_FOLDER_PATH, directory]
		var image_path = "%s/%s/image.jpg" % [_GAMES_FOLDER_PATH, directory]
		var game_exe_path = "%s/%s/game.exe" % [_GAMES_FOLDER_PATH, directory]
		
		# get panel info from "README.md"
		var read_me_text: String = FileAccess.open(read_me_path, FileAccess.READ).get_as_text()
		var regex = RegEx.new()
		regex.compile("#\\s*(.*)\\n(.*)")
		var panel_title: String = regex.search(read_me_text).get_string(1)
		var panel_description: String = regex.search(read_me_text).get_string(2)
		
		# get image
		var image = Image.new()
		var error = image.load(image_path)
		var panel_image_texture
		if error == OK:
			panel_image_texture = ImageTexture.create_from_image(image)
		else:
			print("Failed to load image. Error code: ", error)
		
		# init panel
		panel.initialize_panel(panel_title, panel_description, panel_image_texture, game_exe_path)
		
		# add panel
		panels_hbox.add_child(panel)
	
	# set first panel as active
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
	if event.is_action_pressed("close_application"):
		get_tree().quit()


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
