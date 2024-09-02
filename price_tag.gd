extends StaticBody3D

const SHELF_PLACEMENT_POINT = preload("res://Shelf/shelf_placement_point.tscn")

@onready var label = $PriceTagMesh/Label3D
@onready var price_tag_edit = $PriceTagEdit
@onready var collision_shape_3d := $Area3D/CollisionShape3D

@export var id = 4
@export var price : int

var object_shelf_start_positions : Array
var place_point_nodes : Array
var which_points_are_free : Array
var x_axis_spawn_point_limit : int
var offset : float
var number_of_items_on_shelf := 0
var can_trigger_item := false
var index_to_use : int
var item_id : int

func _ready() -> void:
	EventBus.change_shelf_points_true_false_array_value.connect(edit_array)

func edit_array(index : int, make_false : bool):
	if !which_points_are_free.is_empty() and index <= which_points_are_free.size():
		if make_false:
			which_points_are_free[index] = false
			#print("points that are free array: ", which_points_are_free)
		else:
			which_points_are_free[index] = true
			#print("points that are free array: ", which_points_are_free)

func show_price_tag_editor():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	price_tag_edit.show()

func set_price(new_price : int):
	if new_price is int:
		label.text = str(new_price)
		price = new_price
	else:
		label.text = str("0")

func _on_area_3d_body_entered(body):
	# object_shelf_start_positions array need to be clearedbefore executing again
	if body.get_collision_layer() == 8:
		number_of_items_on_shelf += 1
		body.set_own_price(int(label.text))
		body.is_in_price_tag_area = true
		item_id = body.id
		#body.toggle_collision_layers(true)
		if number_of_items_on_shelf == 1:
			set_shelf_spawn_point_data(body.id)
		else:
			can_trigger_item = true
		if can_trigger_item and body.id == item_id:
			body.set_shelf_data(place_point_nodes, which_points_are_free, self)
			can_trigger_item = false


func _on_area_3d_body_exited(body):
	if body.get_collision_layer() == 8:
		number_of_items_on_shelf -= 1
		body.set_own_price(0)
		body.is_in_price_tag_area = false
		# The var below is set to true on shelf_placement_point.gd
		body.is_on_point = false
		body.toggle_collision_layers(false)
		body.shelf_position = Vector3.ZERO
		body.enable_input_detection()
		index_to_use = body.index
		edit_array(index_to_use, false)
		if number_of_items_on_shelf <= 0:
			object_shelf_start_positions.clear()
			place_point_nodes.clear()
			which_points_are_free.clear()
			item_id = 0
			get_tree().call_group(name, "remove_self")

func set_shelf_spawn_point_data(item_id : int):
	var start_position_1 : Vector3
	var start_position_2 : Vector3
	
	match item_id:
		2:
			"Bagguette"
			start_position_1 = Vector3(-0.834, 0, -0.597)
			start_position_2 = Vector3(-0.834, 0, -0.289)
			x_axis_spawn_point_limit = 3
			offset = 0.842
		3:
			"Peanut butter jar"
			start_position_1 = Vector3(-1.032, 0, -0.604)
			start_position_2 = Vector3(-1.032, 0, -0.306)
			x_axis_spawn_point_limit = 8
			offset = 0.28

	object_shelf_start_positions.append(start_position_1)
	object_shelf_start_positions.append(start_position_2)
	spawn_shelf_placement_points(start_position_1)
	spawn_shelf_placement_points(start_position_2)
	add_spawn_points(start_position_1)
	add_spawn_points(start_position_2)

func add_spawn_points(position_to_change : Vector3):
	var loop_limit = x_axis_spawn_point_limit
	# the subtraction to loop_limit is needed to stop the loop from adding too many placement points
	for points in (loop_limit - 1):
		position_to_change.x += offset
		spawn_shelf_placement_points(position_to_change)

func spawn_shelf_placement_points(pos : Vector3):
	var point = SHELF_PLACEMENT_POINT.instantiate()
	add_child(point)
	point.position = pos
	point.add_to_group(name)
	place_point_nodes.append(point)
	which_points_are_free.append(point.is_free_of_item)
	can_trigger_item = true
