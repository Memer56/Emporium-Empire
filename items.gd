extends RigidBody3D

@export var item_price : int
@export var id = 2

var is_in_price_tag_area : bool
var is_on_point := false
var shelf_position := Vector3.ZERO
var index : int
var price_tag_node : Node
var is_being_looked_at := false

func _ready():
	EventBus.num_of_items_in_world += 1
	if EventBus.loaded_game_file:
		set_process_input(false)

func set_own_price(price : int):
	item_price = price

func despawn():
	await get_tree().create_timer(2).timeout
	queue_free()

func remove_self_from_group():
	self.remove_from_group("items")

func _input(event: InputEvent) -> void:
	if is_in_price_tag_area and Input.is_action_just_pressed("LMB") and !is_on_point:
		move_self_to_shelf_position()

func set_shelf_data(placement_point : Array, which_points_are_free : Array, price_tag : Node):
	if !placement_point.is_empty() and !which_points_are_free.is_empty() and shelf_position == Vector3.ZERO:
		var free_point = which_points_are_free.find(true)
		price_tag_node = price_tag
		index = free_point
		shelf_position = placement_point[free_point].global_position

func move_self_to_shelf_position():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", shelf_position, 0.5)

func toggle_collision_layers(disable_layers : bool):
	if disable_layers:
		set_collision_mask_value(4, false)
	else:
		set_collision_mask_value(4, true)

func enable_input_detection():
	set_process_input(true)
