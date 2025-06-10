class_name PanelTemplate
extends Panel


@export var title_label: RichTextLabel
@export var description_label: RichTextLabel
@export var image_rect: TextureRect


func initialize_panel(new_title: String, new_description: String, new_image_texture: Texture):
	title_label.text = new_title
	description_label.text = new_description
	image_rect.texture = new_image_texture
