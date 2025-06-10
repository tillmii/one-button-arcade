extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(_start_game)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if 


func _start_game():
	var global_path: String = ProjectSettings.globalize_path("res://games/katzensprung/game.exe")
	OS.execute(global_path, [])
	print("Jo")
	pass
