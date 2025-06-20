class_name PanelTemplate
extends Control


@export var title: RichTextLabel
@export var description: RichTextLabel
@export var image: TextureRect


func fill_in_data(game_data: Selector.GameData):
	title.text = "[wave amp=50.0 freq=5.0 connected=1]%s[/wave]" % game_data.title
	description.text = game_data.description
	image.texture = game_data.image_texture
