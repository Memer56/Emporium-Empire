extends Node

signal remove_spawnable
signal display_object(object : PackedScene)
signal object_white
signal recalculate_nav_region
signal toggle_door
signal freeze_npc
signal send_picked_item_data(item_names : Array, placement_position : Vector3)
signal unlock_player_look_axis
signal clicked_on_cash_register
signal image_button_pressed(object_name : String)
signal player_drop_object
signal progress_in_queue
signal reconnect_signal

enum state {
	PLAY,
	BUILDING,
	DESTROYING,
}

enum player_state {
	NORMAL,
	CUTSCENE,
	FLY,
}

var current_state = state.PLAY
var current_player_state
var player_pos = Vector3.ZERO
var checkouts_exist_in_scene := false
var num_of_items_in_world = 0
var id : String
var loaded_game_file_from_main_menu := false
var is_shop_open := true
var npc_heading_to_checkout := false
var cheat_command_entered := false
