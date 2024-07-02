extends Panel
# Supplies headr script

@export var supplies : Node
@export var idk : Node
@export var computer_ui : Node


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var panels_to_disable = [idk]
			computer_ui.toggle_panel_mouse_filter(panels_to_disable, supplies)
