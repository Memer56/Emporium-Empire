extends Control

@onready var text_box = $TextBox
@onready var line_edit = $LineEdit

var cheats = ["fly", "no fly"]

func _on_line_edit_text_submitted(new_text):
	var text = line_edit.text
	var index = cheats.find(text)
	if index != -1:
		var matched_cheat = cheats[index]
		text_box.text += str(matched_cheat, "\n")
		toggle_self()
		if index == 0:
			var new_state = 2
			CheatManager.change_state.emit(new_state)
		if index == 1:
			var new_state = 0
			CheatManager.change_state.emit(new_state)
	else:
		text_box.text += str("Unknown Command", "\n")
	
	line_edit.clear()


func _input(event):
	if Input.is_action_just_pressed("Cheat"):
		toggle_self()

func toggle_self():
	self.visible = not self.visible
	
	if self.visible:
		show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
	else:
		hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false
