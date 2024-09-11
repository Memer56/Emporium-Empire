extends Control

@onready var text_box = $TextBox
@onready var line_edit = $LineEdit

var cheats = ["fly", "no_fly", "money"]


func _on_line_edit_text_submitted(new_text):
	var text = new_text.split(" ")
	var index = cheats.find(text[0])
	var parameters = text.slice(1, text.size())
	if index != -1:
		var matched_cheat = cheats[index]
		text_box.text += str(matched_cheat, "\n")
		toggle_self()
		if index == 0:
			var new_state = "FLY"
			CheatManager.change_player_state(new_state)
		if index == 1:
			var new_state = "NORMAL"
			CheatManager.change_player_state(new_state)
		if index == 2:
			var new_value = parameters[1]
			if parameters[0] == "+":
				EventBus.update_money_counter.emit(int(new_value), "add")
			elif parameters[0] == "-":
				EventBus.update_money_counter.emit(int(new_value), "subtract")

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
