extends StaticBody3D

@export var id = 9
@onready var computer_ui = $ComputerUI


func _unhandled_input(event):
	if event is InputEventMouseButton:
		# Fix below below condition to check game mode to prevent ui from displaying
		if event.button_index == MOUSE_BUTTON_LEFT:
			computer_ui.toggle_self()
