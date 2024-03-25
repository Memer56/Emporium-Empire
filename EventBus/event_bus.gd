extends Node

signal remove_spawnable
signal display_object(object : PackedScene)
signal object_white
signal recalculate_nav_region
signal toggle_door
signal freeze_npc
signal spawn_picked_items(item_names : Array, placement_position : Vector3)
signal unlock_player_look_axis
signal clicked_on_cash_register
signal payed_for_items
signal spawn_money(placement_position : Vector3)
signal image_button_pressed(object_name : String)

enum state {
	PLAY,
	BUILDING,
	DESTROYING,
}

var current_state = state.PLAY
var player_pos = Vector3.ZERO
var checkouts_exist_in_scene = false
var num_of_items_in_world = 0
