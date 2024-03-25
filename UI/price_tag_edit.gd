extends Control

@onready var line_edit = $Panel/LineEdit


func _on_line_edit_text_submitted(_new_text):
	var new_price = line_edit.text
	set_price(float(new_price))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	EventBus.unlock_player_look_axis.emit()
	hide()

func _on_cancel_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventBus.unlock_player_look_axis.emit()
	get_tree().paused = false
	hide()

func set_price(new_price : float):
	get_parent().set_price(new_price)
