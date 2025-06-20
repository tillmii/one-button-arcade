extends Control


@onready var texture_rect: TextureRect = $TextureRect
@onready var gradient: TextureRect = $Gradient
@onready var background: ColorRect = $Circle/Background
@onready var dots: ColorRect = $Circle/Background/Dots

var current_tween: Tween


var colors = [Color("#7E52A0"), Color("#00ccc1"), Color("#cf5a00")]
var color_idx = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#current_tween = create_tween()
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if not current_tween:
			current_tween = create_tween()
			current_tween.finished.connect(func(): current_tween = null)
			current_tween.tween_property(texture_rect, "rotation_degrees", 90, 1).as_relative().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
			
			var tween_bg = create_tween()
			tween_bg.tween_property(background, "color", colors[color_idx], 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
			
			var tween_horizon = create_tween()
			tween_horizon.tween_property(gradient, "texture:gradient:colors", PackedColorArray([colors[color_idx], Color("#000000")]), 1)#.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
			
			var tween_dots = create_tween()
			tween_dots.tween_property(dots, "material:shader_parameter/circle_color", colors[color_idx].darkened(-.5), 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)

			color_idx = (color_idx + 1) % (colors.size())
