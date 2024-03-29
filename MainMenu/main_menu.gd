extends Control

@onready var animation_player = $AnimationPlayer
@onready var main_buttons = $MainButtons
@onready var save_slots = $SaveSlots
@onready var slot_label_1 = $SaveSlots/SaveSlot1/SlotLabel1
@onready var slot_label_2 = $SaveSlots/SaveSlot2/SlotLabel2
@onready var slot_label_3 = $SaveSlots/SaveSlot3/SlotLabel3
@onready var slot_label_4 = $SaveSlots/SaveSlot4/SlotLabel4
@onready var slot_label_5 = $SaveSlots/SaveSlot5/SlotLabel5
@onready var confirm_panel = $ConfirmPanel

var main = "res://Main/main.tscn"
var save : SaveGame
var time
var save_file_id : String
var slot_label_name 

func _ready():
	check_for_save_files()

func _process(delta):
	time = Time.get_datetime_dict_from_system()

func _on_new_game_pressed():
	animation_player.play("Fade")


func _on_load_game_pressed():
	display_save_slots()


func _on_quit_game_pressed():
	get_tree().quit()

func change_scene():
	get_tree().change_scene_to_file.bind(main).call_deferred()

func display_save_slots():
	main_buttons.hide()
	save_slots.show()


func _on_delete_save_pressed():
	var id = "_Save1"
	delete_save_file(id, slot_label_1)

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


func _on_save_slot_1_pressed():
	var id = "_Save1"
	load_game(id)


func _on_save_slot_2_pressed():
	var id = "_Save2"
	load_game(id)


func _on_save_slot_3_pressed():
	var id = "_Save3"
	load_game(id)


func _on_save_slot_4_pressed():
	var id = "_Save4"
	load_game(id)


func _on_save_slot_5_pressed():
	var id = "_Save5"
	load_game(id)


func _on_back_pressed():
	main_buttons.show()
	save_slots.hide()


func _on_delete_save_1_pressed():
	confirm_panel.show()
	save_file_id = "_Save1"
	slot_label_name = slot_label_1


func _on_delete_save_2_pressed():
	pass # Replace with function body.


func _on_delete_save_3_pressed():
	pass # Replace with function body.


func _on_delete_save_4_pressed():
	pass # Replace with function body.


func _on_delete_save_5_pressed():
	pass # Replace with function body.


func load_game(id : String):
	EventBus.id = id
	EventBus.loaded_game_file_from_main_menu = true
	animation_player.play("Fade")

func delete_save_file(id : String, label : Control):
	save = SaveGame.delete_savegame(id)
	label.text = str("Empty Save")
	label.add_theme_font_size_override("font_size", 60)


func _on_confirm_button_pressed():
	delete_save_file(save_file_id, slot_label_name)
	confirm_panel.hide()


func _on_deny_button_pressed():
	confirm_panel.hide()
