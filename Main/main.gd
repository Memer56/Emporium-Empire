extends Node3D

# Credit Kenny if this game goes public
const BAGUETTE = preload("res://Items/baguette.tscn")
const PEANUT_BUTTER_JAR = preload("res://Items/peanut_butter_jar.tscn")
const CASH = preload("res://Cash/cash.tscn")
const SHELF = preload("res://Shelf/shelf.tscn")
const PRICE_TAG = preload("res://price_tag.tscn")
const CHECKOUT = preload("res://Objects/checkout.tscn")

@onready var navigation_region = $NavigationRegion3D
@onready var player = $Player
@onready var marker = $Marker3D
@onready var num : int
@export var spawn_things = false

var nav_rebake_finished = true
var save : SaveGame
var item_data 


func _ready():
	EventBus.recalculate_nav_region.connect(recalculate_nav_region)
	EventBus.send_picked_item_data.connect(spawn_picked_items)
	EventBus.unlock_player_look_axis.connect(unlock_player_look_axis)
	EventBus.spawn_money.connect(spawn_money)
	if EventBus.loaded_game_file_from_main_menu:
		_on_pause_menu_load_game(EventBus.id)
	if spawn_things:
		spawn_thing()
	#for items in get_tree().get_nodes_in_group("items"):
		#print(str(items.name, items.global_position))


func _process(_delta):
	if get_node_or_null("NavigationRegion3D/Checkout"):
		EventBus.checkouts_exist_in_scene = true
	else:
		EventBus.checkouts_exist_in_scene = false


func recalculate_nav_region():
	if nav_rebake_finished:
		navigation_region.bake_navigation_mesh(true)
		nav_rebake_finished = false
		navigation_region.bake_finished.emit()

func spawn_picked_items(item_data : Array, placement_position : Vector3):
	print("items_id's: ", item_data)
	EventBus.send_picked_item_data.disconnect(spawn_picked_items)
	for index in item_data.size():
		print("looping through items")
		var data = item_data[index]
		var id = data[0]
		match id:
			1:
				pass
			2:
				print("spawning bread")
				var item = BAGUETTE.instantiate()
				instance_items(item, placement_position)
			3:
				print("spawning jar")
				var item = PEANUT_BUTTER_JAR.instantiate()
				instance_items(item, placement_position)

func instance_items(item, placement_position):
	add_child(item)
	item.global_position = placement_position + Vector3(0, 0, randf_range(0, 0.2))

func spawn_money(placement_position : Vector3):
	var cash = CASH.instantiate()
	add_child(cash)
	cash.global_position = placement_position + Vector3(0, 2, 0)

func unlock_player_look_axis():
	player.locked = false

func _on_navigation_region_3d_bake_finished():
	nav_rebake_finished = true


func _on_pause_menu_save_game(id : String):
	save = SaveGame.new()
	save.player_pos = player.global_position
	for item in get_tree().get_nodes_in_group("save"):
		var object_info = []
		var positions = item.global_position
		var item_id = item.id
		var object_rotation = item.global_rotation_degrees
		var price := 0.0
		if item.id == 4:
			price = item.price
		object_info.append(item_id)
		object_info.append(positions)
		object_info.append(object_rotation)
		object_info.append(price)
		save.item_and_object_pos.append(object_info)
	save.write_savegame(id)


func _on_pause_menu_load_game(id : String):
	if SaveGame.save_exists(id) == false:
		push_error("No Save File Was Found")
		return
	# reload scene before executing this or it causes duplication glitch
	save = SaveGame.load_savegame(id)
	player.global_position = save.player_pos
	item_data = save.item_and_object_pos
	rebake_navmesh()
	for index in item_data.size():
		var data = item_data[index]
		var item_id = data[0]
		var pos = data[1]
		var rot = data[2]
		var new_price = data[3]
		var item_name : PackedScene
		match item_id:
			1:
				pass
				#item_name = PEANUT_BUTTER_JAR
				#var itemName = item_name.instantiate()
				#add_child(itemName)
				#itemName.global_position = pos
			2:
				item_name = BAGUETTE
				var itemName = item_name.instantiate()
				add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
			3:
				item_name = PEANUT_BUTTER_JAR
				var itemName = item_name.instantiate()
				add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
			4:
				item_name = PRICE_TAG
				var itemName = item_name.instantiate()
				add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.set_price(new_price)
			5:
				item_name = SHELF
				var itemName = item_name.instantiate()
				get_tree().root.get_node("Main/NavigationRegion3D").add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.despawn_extra_price_tags()
				itemName.object_white()
			6:
				item_name = CHECKOUT
				var itemName = item_name.instantiate()
				get_tree().root.get_node("Main/NavigationRegion3D").add_child(itemName)
				itemName.global_position = pos
				itemName.global_rotation_degrees = rot
				itemName.object_white()

func rebake_navmesh():
	await get_tree().create_timer(1).timeout
	navigation_region.bake_navigation_mesh()
