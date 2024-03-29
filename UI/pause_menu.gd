extends Control

signal save_game(id : String)
signal load_game(id : String)

@onready var main_buttons = $MenuBackground/MainButtons
@onready var save_slots = $MenuBackground/SaveSlots
@onready var title = $MenuBackground/Title
@onready var slot_label_1 = $MenuBackground/SaveSlots/SaveSlot1/SlotLabel_1
@onready var slot_label_2 = $MenuBackground/SaveSlots/SaveSlot2/SlotLabel_2
@onready var slot_label_3 = $MenuBackground/SaveSlots/SaveSlot3/SlotLabel_3
@onready var slot_label_4 = $MenuBackground/SaveSlots/SaveSlot4/SlotLabel_4
@onready var slot_label_5 = $MenuBackground/SaveSlots/SaveSlot5/SlotLabel_5


var was_saved_pressed := false
var time
var save : SaveGame


func _ready():
	check_for_save_files()

func _process(delta):
	time = Time.get_datetime_dict_from_system()


func check_for_save_files():
	if SaveGame.save_exists("_Save1"):
		load_save_file_names_to_slots("_Save1", "Save Game 1 - ", slot_label_1)
	
	if SaveGame.save_exists("_Save2"):
		load_save_file_names_to_slots("_Save2", "Save Game 2 - ", slot_label_2)
	
	if SaveGame.save_exists("_Save3"):
		load_save_file_names_to_slots("_Save3", "Save Game 3 - ", slot_label_3)
	
	if SaveGame.save_exists("_Save4"):
		load_save_file_names_to_slots("_Save4", "Save Game 4 - ", slot_label_4)
	
	if SaveGame.save_exists("_Save5"):
		load_save_file_names_to_slots("_Save5", "Save Game 5 - ", slot_label_5)

func load_save_file_names_to_slots(id : String, text : String, label : Control):
	var save_date_from_file
	save = SaveGame.load_savegame(id)
	save_date_from_file = save.this_save_date
	label.text = str(text, save_date_from_file)
	label.add_theme_font_size_override("font_size", 30)

func _on_resume_game_pressed():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()


func _on_options_menu_pressed():
	pass # Replace with function body.


func _on_save_game_pressed():
	display_save_slots(true, "Save Game")


func _on_load_game_pressed():
	display_save_slots(false, "Load Game")


func _on_main_menu_pressed():
	get_tree().change_scene_to_file.bind("res://MainMenu/main_menu.tscn").call_deferred()


func _on_quit_game_pressed():
	get_tree().quit()

func play_hover_sound_effect():
	pass

func _input(event):
	if Input.is_action_just_pressed("ESC"):
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		show()

func display_save_slots(save_pressed : bool, text : String):
	main_buttons.hide()
	save_slots.show()
	title.text = text
	if save_pressed:
		was_saved_pressed = true


func _on_save_slot_1_pressed():
	save_or_load_data("_Save1", "Save Game 1 - ", slot_label_1)


func _on_save_slot_2_pressed():
	save_or_load_data("_Save2", "Save Game 2 - ", slot_label_2)


func _on_save_slot_3_pressed():
	save_or_load_data("_Save3", "Save Game 3 - ", slot_label_3)


func _on_save_slot_4_pressed():
	save_or_load_data("_Save4", "Save Game 4 - ", slot_label_4)


func _on_save_slot_5_pressed():
	save_or_load_data("_Save5", "Save Game 5 - ", slot_label_5)


func _on_back_pressed():
	main_buttons.show()
	save_slots.hide()
	was_saved_pressed = false
	title.text = "Pause Menu"

func save_or_load_data(id : String, text : String, label : Control):
	if was_saved_pressed:
		var save_date = str("%02d:%02d:%02d %02d:%02d:%02d" % [time.day, time.month, time.year, time.hour, time.minute, time.second])
		save_game.emit(id)
		label.text = str(text, save_date)
		label.add_theme_font_size_override("font_size", 30)
	else:
		load_game.emit(id)
