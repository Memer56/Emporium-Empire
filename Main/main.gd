extends Node3D

# Credit Kenny if this game goes public
const BAGUETTE = preload("res://Items/baguette.tscn")
const PEANUT_BUTTER_JAR = preload("res://Items/peanut_butter_jar.tscn")
const SANDWICH = preload("res://Items/sandwich.tscn")
const SHELF = preload("res://Shelf/shelf.tscn")
const PRICE_TAG = preload("res://price_tag.tscn")
const CHECKOUT = preload("res://Objects/checkout.tscn")
const COMPUTER = preload("res://Objects/Computer/computer.tscn")
const GODOT_PLUSHIE_SMALL = preload("res://Items/Godot Plushie/godot_plushie_small.tscn")
const SMALL_WALL = preload("res://Objects/Building Parts/small_wall.tscn")
const MEDIUM_WALL = preload("res://Objects/Building Parts/medium_wall.tscn")
const LARGE_WALL = preload("res://Objects/Building Parts/large_wall.tscn")
const DESK = preload("res://Furniture/Furniture Scenes/desk.tscn")

@onready var navigation_region = $NavigationRegion3D
@onready var house_nav_mesh = $HouseNavMesh
@onready var player = $Player
@onready var marker = $Marker3D
@onready var num : int


var nav_rebake_finished = true
var save : SaveGame
var item_data
var price_tag_name_num := 1
var num_of_price_tags : int
var parsed_game_version : String
var version = ProjectSettings.get_setting("application/config/version")


func _ready():
	EventBus.recalculate_nav_region.connect(recalculate_nav_region)
	EventBus.send_picked_item_data.connect(spawn_picked_items)
	EventBus.unlock_player_look_axis.connect(unlock_player_look_axis)
	EventBus.reconnect_signal.connect(reconnect_signal)
	get_tree().paused = false
	if EventBus.loaded_game_file:
		fetch_game_data(EventBus.id)
	# The below code is to prevent issues with items recieving the neede shelf data
	await get_tree().create_timer(1).timeout
	EventBus.loaded_game_file = false

func _process(_delta):
	if get_node_or_null("NavigationRegion3D/Checkout"):
		EventBus.checkouts_exist_in_scene = true
	else:
		EventBus.checkouts_exist_in_scene = false


func recalculate_nav_region():
	if EventBus.player_is_in_house:
		house_nav_mesh.bake_navigation_mesh(true)
	
	if nav_rebake_finished and !EventBus.player_is_in_house:
		navigation_region.bake_navigation_mesh(true)
		nav_rebake_finished = false
		navigation_region.bake_finished.emit()

func spawn_picked_items(item_data : Array, placement_position : Vector3):
	EventBus.send_picked_item_data.disconnect(spawn_picked_items)
	for index in item_data.size():
		var data = item_data[index]
		var id = data[0]
		match id:
			1:
				var item = SANDWICH.instantiate()
				instance_items(item, placement_position)
			2:
				var item = BAGUETTE.instantiate()
				instance_items(item, placement_position)
			3:
				var item = PEANUT_BUTTER_JAR.instantiate()
				instance_items(item, placement_position)

func instance_items(item, placement_position):
	add_child(item)
	item.global_position = placement_position + Vector3(0, 0, randf_range(0, 0.2))
	item.remove_self_from_group()

func reconnect_signal():
	EventBus.send_picked_item_data.connect(spawn_picked_items)

func unlock_player_look_axis():
	player.locked = false

func _on_navigation_region_3d_bake_finished():
	nav_rebake_finished = true


func _on_pause_menu_save_game(id : String):
	# To solve prive tag issue maybe save and load shelf data such as true/false array
	save = SaveGame.new()
	save.player_pos = player.global_position
	save.game_version = version
	save.money = EventBus.money
	for item in get_tree().get_nodes_in_group("save"):
		var object_info = []
		var positions = item.global_position
		var item_id = item.id
		var object_rotation = item.global_rotation_degrees
		var price := 0.0
		var colour : Color
		var item_index : int
		var shelf_points := {
			"Free points array:": []
		}
		if item.id == 4:
			price = item.price
		if item.is_in_group("has colour"):
			colour = item.object_colour
		if item.is_in_group("items"):
			item_index = item.index
		if item.is_in_group("price_tag"):
			shelf_points["Free points array:"] = item.which_points_are_free
		object_info.append(item_id)
		object_info.append(positions)
		object_info.append(object_rotation)
		object_info.append(price)
		object_info.append(colour)
		object_info.append(item_index)
		object_info.append(shelf_points)
		save.item_and_object_pos.append(object_info)
	save.write_savegame(id)


func _on_pause_menu_load_game(id : String):
	EventBus.id = id
	get_tree().change_scene_to_file("res://Load Screen/load_screen.tscn")

func fetch_game_data(id : String):
	if SaveGame.save_exists(id) == false:
		push_error("No Save File Was Found")
		return
	save = SaveGame.load_savegame(id)
	#parsed_game_version = save.game_version
	load_game_data(save)

func load_game_data(save):
	player.global_position = save.player_pos
	item_data = save.item_and_object_pos
	EventBus.money = save.money
	EventBus.update_money_counter.emit(EventBus.money, "")
	rebake_navmesh()
	for index in item_data.size():
		var data = item_data[index]
		var item_id = data[0]
		var pos = data[1]
		var rot = data[2]
		var new_price = data[3]
		var colour = data[4]
		var item_index = data[5]
		var shelf_points = data[6]
		var item_name : PackedScene
		var item_name_2 : PackedScene
		match item_id:
			1:
				item_name = SANDWICH
				var itemName = item_name.instantiate()
				add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.index = item_index
			2:
				item_name = BAGUETTE
				var itemName = item_name.instantiate()
				add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.index = item_index
			3:
				item_name = PEANUT_BUTTER_JAR
				var itemName = item_name.instantiate()
				add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.index = item_index
			4:
				num_of_price_tags += 1
				if num_of_price_tags == 11:
					num_of_price_tags = 0
					price_tag_name_num += 1
				item_name = PRICE_TAG
				var itemName = item_name.instantiate()
				var node_path = "Main/NavigationRegion3D/Shelf" + str(price_tag_name_num)
				get_tree().root.get_node(node_path).add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.set_price(new_price)
				itemName.initialise_free_point_array(shelf_points["Free points array:"])
			5:
				item_name = SHELF
				var itemName = item_name.instantiate()
				get_tree().root.get_node("Main/NavigationRegion3D").add_child(itemName, true)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.despawn_extra_price_tags()
				itemName.set_colour(colour)
			6:
				item_name = CHECKOUT
				var itemName = item_name.instantiate()
				get_tree().root.get_node("Main/NavigationRegion3D").add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.set_colour(colour)
			9:
				item_name = COMPUTER
				var itemName = item_name.instantiate()
				add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.set_colour(colour)
			11:
				item_name = GODOT_PLUSHIE_SMALL
				var itemName = item_name.instantiate()
				add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
			12:
				item_name = SMALL_WALL
				var itemName = item_name.instantiate()
				add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.set_colour(colour)
			13:
				item_name = MEDIUM_WALL
				var itemName = item_name.instantiate()
				add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.set_colour(colour)
			14:
				item_name = LARGE_WALL
				var itemName = item_name.instantiate()
				add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.set_colour(colour)
			15:
				item_name = DESK
				var itemName = item_name.instantiate()
				add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.set_colour(colour)

func rebake_navmesh():
	await get_tree().create_timer(1).timeout
	navigation_region.bake_navigation_mesh(true)
