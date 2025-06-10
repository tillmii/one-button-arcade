class_name PanelTemplate
extends Panel


const _TIME_TO_TRIGGER_GAME_START: float = 2.0


@export var title_label: RichTextLabel
@export var description_label: RichTextLabel
@export var image_rect: TextureRect
@export var button_progress_bar: TextureProgressBar

var game_exe_path: String = ""
var panel_is_active: bool = false

var button_is_pressed: bool = false
var button_pressed_time: float = 0.0


func initialize_panel(new_title: String, new_description: String, new_image_texture: Texture, new_path: String):
	title_label.text = new_title
	description_label.text = new_description
	image_rect.texture = new_image_texture
	game_exe_path = new_path


func _process(delta: float) -> void:
	
	# Update radial button visual
	if button_is_pressed:
		button_pressed_time += delta
	else:
		button_pressed_time = 0.0
	button_progress_bar.value = button_pressed_time
	
	# Start game condition
	if panel_is_active and button_pressed_time > _TIME_TO_TRIGGER_GAME_START:
		print("START GAME ", game_exe_path)


func start_game():
	OS.execute(game_exe_path, [])
