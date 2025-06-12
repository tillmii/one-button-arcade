class_name Dot
extends TextureRect


@onready var application: Application = self.get_parent().get_parent().get_parent()


func _ready() -> void:
	application.connect("set_active_dot", set_active_dot)

func set_active_dot(active_dot: Dot):
	self.modulate = Color.WHITE
	if active_dot == self:
		self.modulate = Color.RED
