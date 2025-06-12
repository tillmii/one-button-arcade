class_name GamePanel
extends Panel


# constants
const _TIME_TO_TRIGGER_GAME_START: float = 2.0

# export
@export var title_label: RichTextLabel
@export var description_label: RichTextLabel
@export var image_rect: TextureRect
@export var button_progress_bar: TextureProgressBar
@onready var application: Application = self.get_parent().get_parent()

# variables
var game_exe_path: String = ""
var panel_is_active: bool = false
var button_is_pressed: bool = false
var button_pressed_time: float = 0.0
var game_ongoing: bool = false


func initialize_panel(new_title: String, new_description: String, new_image_texture: Texture, new_path: String):
	title_label.text = new_title
	description_label.text = new_description
	image_rect.texture = new_image_texture
	game_exe_path = new_path


func _ready() -> void:
	application.connect("button_pressed", button_pressed)
	application.connect("button_released", button_release)
	application.connect("set_active_panel", set_active_panel)


func _process(delta: float) -> void:
	update_button_pressed_time(delta)
	update_button_value(button_pressed_time)
	
	# Start game condition
	if panel_is_active and button_pressed_time > _TIME_TO_TRIGGER_GAME_START and !game_ongoing:
		start_game()
		game_ongoing = true


func update_button_pressed_time(delta: float):
	if button_is_pressed:
		button_pressed_time += delta
	else:
		button_pressed_time = 0.0


func update_button_value(new_value: float):
	button_progress_bar.value = new_value


func button_pressed():
	button_is_pressed = true


func button_release():
	button_is_pressed = false


func set_active_panel(active_panel: GamePanel):
	panel_is_active = false
	if active_panel == self:
		panel_is_active = true


func start_game():
	var global_path: String = ProjectSettings.globalize_path(game_exe_path)
	OS.execute(global_path, [])
