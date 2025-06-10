extends TextureRect

var selected: bool = false:
	set(value):
		selected = value
		if selected:
			self.modulate = Color.RED
		else:
			self.modulate = Color.BLACK
