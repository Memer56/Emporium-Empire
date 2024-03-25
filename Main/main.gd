extends Node3D

# Credit Kenny if this game goes public
const BAGUETTE = preload("res://Items/baguette.tscn")
const PEANUT_BUTTER_JAR = preload("res://Items/peanut_butter_jar.tscn")
const CASH = preload("res://Cash/cash.tscn")

@onready var navigation_region = $NavigationRegion3D
@onready var player = $Player
@onready var marker = $Marker3D
@onready var num : int

var nav_rebake_finished = true


func _ready():
	EventBus.recalculate_nav_region.connect(recalculate_nav_region)
	EventBus.spawn_picked_items.connect(spawn_picked_items)
	EventBus.unlock_player_look_axis.connect(unlock_player_look_axis)
	EventBus.spawn_money.connect(spawn_money)
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

func spawn_picked_items(item_names : Array, placement_position : Vector3):
	if item_names.has(2):
		var item_count = item_names.count(2)
		var n = 0
		while n < item_count:
			var item = BAGUETTE.instantiate()
			instance_items(item, placement_position)
			n += 1
	
	if item_names.has(3):
		var item_count = item_names.count(3)
		var n = 0
		while n < item_count:
			var item = PEANUT_BUTTER_JAR.instantiate()
			instance_items(item, placement_position)
			n += 1

func instance_items(item, placement_position):
	add_child(item)
	item.global_position = placement_position + Vector3(0, 2, randf_range(0, 1))

func spawn_money(placement_position : Vector3):
	var cash = CASH.instantiate()
	add_child(cash)
	cash.global_position = placement_position + Vector3(0, 2, 1)

func unlock_player_look_axis():
	player.locked = false

func _on_navigation_region_3d_bake_finished():
	nav_rebake_finished = true

