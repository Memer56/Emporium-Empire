extends Node

signal remove_spawnable
signal display_object(object : PackedScene)
signal recalculate_nav_region
signal freeze_npc
signal send_picked_item_data(item_names : Array, placement_position : Vector3)
signal unlock_player_look_axis
signal clicked_on_cash_register
signal image_button_pressed(object_name : String, new_colour : Color)
signal player_drop_object
signal progress_in_queue
signal reconnect_signal
signal send_confirmed_order(basket : Array)
signal change_shelf_points_true_false_array_value(index : int, make_false : bool)

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
var loaded_game_file := false
var is_shop_open := false
var npc_heading_to_checkout := false
var cheat_command_entered := false
var player_is_in_house := false
var npc_spawn_points : Array
var player_level : int
var last_item_placed_on_shelf : String
