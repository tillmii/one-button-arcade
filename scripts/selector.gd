class_name Selector
extends Control


class GameData:
	var title: String
	var description: String
	var image_texture: Texture
	var color: Color
	var path_to_exe: String
	
	func _init(_title, _description, _image_texture, _color, _path_to_exe):
		self.title = _title
		self.description = _description
		self.image_texture = _image_texture
		self.color = _color
		self.path_to_exe = _path_to_exe


# Game Data
@onready var _games: Array[GameData] = []
@onready var game_idx: int = 0

# Exports
@export var game_container: TextureRect
@export var gradient: TextureRect
@export var background: ColorRect
@export var dots: ColorRect
@export var current_panel_template: PanelTemplate
@export var next_panel_template: PanelTemplate
@export var short_press_timer: Timer
@export var long_press_timer: Timer

# Tweening stuff
var current_tween: Tween
var colors = [Color("#7E52A0"), Color("#00ccc1"), Color("#cf5a00")]
var color_idx = 0
var _ANIMATION_TIME = 1.0

# Paths and Scenes
const _GAMES_FOLDER_PATH: String = "user://one-button-games/"
const _PANEL_TEMPLATE = preload("res://scenes/panel_template.tscn")
const _PIVOT_OFFSET = Vector2(960.0, 2200.0)

# Timer stuff
#

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().set_auto_accept_quit(false)
	
	await get_tree().process_frame
	
	# Read all games
	var games_folder_dir = DirAccess.open(_GAMES_FOLDER_PATH)
	for directory in games_folder_dir.get_directories():
		
		# Set all data paths
		var read_me_path = "%s/%s/README.md" % [_GAMES_FOLDER_PATH, directory]
		var image_path = "%s/%s/image.jpg" % [_GAMES_FOLDER_PATH, directory]
		var game_exe_path = "%s/%s/game.exe" % [_GAMES_FOLDER_PATH, directory]
		
		# Get panel info from "README.md"
		var read_me_text: String = FileAccess.open(read_me_path, FileAccess.READ).get_as_text()
		var regex = RegEx.new()
		regex.compile("#\\s*(.*)\\n(.*)")
		var game_title: String = regex.search(read_me_text).get_string(1)
		var game_description: String = regex.search(read_me_text).get_string(2)
		
		# Get image
		var image = Image.new()
		var error = image.load(image_path)
		var panel_image_texture
		if error == OK:
			panel_image_texture = ImageTexture.create_from_image(image)
		else:
			print("Failed to load image. Error code: ", error)
		
		# Create game data object and add it to the list
		var game: GameData = GameData.new(game_title, game_description, panel_image_texture, colors.pick_random(), game_exe_path)
		_games.append(game)
	
	# Set first two containers
	if _games.is_empty():
		return
	current_panel_template.fill_in_data(_games[0])
	next_panel_template.fill_in_data(_games[1])
	
	# Timer signals
	short_press_timer.connect("timeout", short_press_timer_timeout)
	long_press_timer.connect("timeout", long_press_timer_timeout)


func _process(delta: float) -> void:
	if long_press_timer.time_left > 0 and not long_press_timer.is_stopped():
		current_panel_template.progress_bar.value = remap(long_press_timer.wait_time - long_press_timer.time_left, 0.0, long_press_timer.wait_time, 0.0, 100.0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if not current_tween:
			short_press_timer.start()
	if event.is_action_released("left_click"):
		if short_press_timer.time_left > 0.0:
			short_press_input()
		if long_press_timer.time_left > 0.0:
			long_press_abort()
	if event.is_action_pressed("close_application"):
		get_tree().quit()


func short_press_input():
	short_press_timer.stop()
	spin_wheel()
	tween_colors()


func short_press_timer_timeout():
	long_press_timer.start()


func long_press_abort():
	long_press_timer.stop()
	var tween = create_tween()
	tween.tween_property(current_panel_template.progress_bar, "value", 0, .2)


func long_press_timer_timeout():
	long_press_timer.stop()
	current_panel_template.progress_bar.value = 0.0
	await get_tree().process_frame
	OS.execute(ProjectSettings.globalize_path(_games[posmod(game_idx, _games.size())].path_to_exe), [])


func spin_wheel():
	current_tween = create_tween()
	current_tween.finished.connect(finished_spinning)
	current_tween.tween_property(game_container, "rotation_degrees", 90, _ANIMATION_TIME).as_relative().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)


func tween_colors():
	
	# Change background color
	var tween_bg = create_tween()
	tween_bg.tween_property(background, "color", _games[posmod(game_idx + 1, _games.size())].color, _ANIMATION_TIME).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	
	# Change horizon color
	var tween_horizon = create_tween()
	tween_horizon.tween_property(gradient, "texture:gradient:colors", PackedColorArray([_games[posmod(game_idx + 1, _games.size())].color, Color("#000000")]), _ANIMATION_TIME).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	
	# Change dot color
	var tween_dots = create_tween()
	tween_dots.tween_property(dots, "material:shader_parameter/circle_color", _games[posmod(game_idx + 1, _games.size())].color.darkened(-.5), _ANIMATION_TIME).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	
	color_idx = (color_idx + 1) % (colors.size())


func finished_spinning():
	current_tween = null
	swap_game_container()


func swap_game_container():
	
	# Swap containers
	var temp_panel_template = current_panel_template
	current_panel_template = next_panel_template
	next_panel_template = temp_panel_template
	
	# Rotate old panel back
	next_panel_template.rotation_degrees -= 180.0
	
	# Set next game data
	next_panel_template.fill_in_data(_games[posmod(game_idx + 2, _games.size())])
	game_idx = posmod((game_idx + 1), _games.size())
