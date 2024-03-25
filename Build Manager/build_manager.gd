extends Node3D

@onready var shelf : PackedScene = ResourceLoader.load("res://Shelf/shelf.tscn")
@onready var small_wall : PackedScene = ResourceLoader.load("res://Objects/Building Parts/small_wall.tscn")
@onready var medium_wall : PackedScene = ResourceLoader.load("res://Objects/Building Parts/medium_wall.tscn")
@onready var large_wall : PackedScene = ResourceLoader.load("res://Objects/Building Parts/large_wall.tscn")
@onready var checkout : PackedScene = ResourceLoader.load("res://Objects/checkout.tscn")
var current_spawnable
var able_to_build = true
var edit_mode = false
var current_position_y
var target_position = Vector3.ZERO
var holding_shift = false
var selected_build_object = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if EventBus.current_state == EventBus.state.BUILDING and !edit_mode:
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
		var cursor_pos = Plane(Vector3.UP, position.y).intersects_ray(from, to)
		if cursor_pos and !selected_build_object:
			current_spawnable.global_position.x = cursor_pos.x
			current_spawnable.global_position.z = cursor_pos.z
		elif cursor_pos and selected_build_object:
			current_spawnable.global_position.x = roundf(cursor_pos.x)
			current_spawnable.global_position.z = roundf(cursor_pos.z)
		else:
			current_spawnable.queue_free()
			EventBus.current_state = EventBus.state.PLAY
		#The code below appears twicw in order to be usable in both conditions
		if able_to_build:
			place_object()
	elif EventBus.current_state == EventBus.state.BUILDING:
		if able_to_build:
			place_object()
	else:
		if current_spawnable != null:
			current_spawnable.queue_free()
			current_spawnable = null
	
	if EventBus.current_state == EventBus.state.DESTROYING:
		#This code below removes objects
		edit_mode = false
		if Input.is_action_just_released("LMB"):
			EventBus.remove_spawnable.emit()
		
	if Input.is_action_just_pressed("EditMode"):
		toggle_adjust_mode()

func place_object():
	if Input.is_action_just_released("LMB"):
		selected_build_object = false
		var obj = current_spawnable.duplicate()
		get_tree().root.get_node("Main/NavigationRegion3D").add_child(obj)
		obj.global_position = current_spawnable.global_position
		EventBus.recalculate_nav_region.emit()
		EventBus.object_white.emit()
		EventBus.current_state = EventBus.state.PLAY

func toggle_adjust_mode():
	edit_mode = not edit_mode
	if edit_mode:
		edit_mode = true
	else:
		edit_mode = false

func rotate_and_adjust(to_rotate : bool, change_height : bool, move_left : bool, move_right : bool, positive_negative_value : int):
	if to_rotate:
		current_spawnable.rotate_y(deg_to_rad(-22.5))
	if change_height:
		current_spawnable.position.y += 0.25 * positive_negative_value
	if move_left:
		target_position = (current_spawnable.global_transform.origin * 90) + current_spawnable.global_transform.basis.x * positive_negative_value
		if not holding_shift:
			current_spawnable.global_transform.origin -= current_spawnable.global_transform.basis.x * 0.25
		else:
			current_spawnable.global_transform.origin -= current_spawnable.global_transform.basis.z * 0.25
	if move_right:
		target_position = (current_spawnable.global_transform.origin * 90) + current_spawnable.global_transform.basis.x * positive_negative_value
		if not holding_shift:
			current_spawnable.global_transform.origin += current_spawnable.global_transform.basis.x * 0.25
		else:
			current_spawnable.global_transform.origin += current_spawnable.global_transform.basis.z * 0.25


func spawn_shelf():
	spawn_object(shelf)

func spawn_small_wall():
	spawn_object(small_wall)

func spawn_medium_wall():
	spawn_object(medium_wall)

func spawn_large_wall():
	spawn_object(large_wall)

func spawn_checkout():
	spawn_object(checkout)

func spawn_object(obj):
	if current_spawnable != null:
		current_spawnable.queue_free()
	
	current_spawnable = obj.instantiate()
	add_child(current_spawnable)
	EventBus.current_state = EventBus.state.BUILDING

func _input(event):
	if EventBus.current_state == EventBus.state.BUILDING and edit_mode:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				rotate_and_adjust(true, false, false, false, 1)
		# CHANGE THIS TO ADJUST HEIGHT WITH ARROW KEYS
		if Input.is_action_just_pressed("ArrowUp"):
			rotate_and_adjust(false, true, false, false, 1)
		if Input.is_action_just_pressed("ArrowDown"):
			rotate_and_adjust(false, true, false, false, -1)
		if Input.is_action_just_pressed("ArrowLeft"):
			rotate_and_adjust(false, false, true, false, 0)
		if Input.is_action_just_pressed("ArrowRight"):
			rotate_and_adjust(false, false, false, true, 0)
		if Input.is_action_pressed("Shift"):
			holding_shift = true
		elif Input.is_action_just_released("Shift"):
			holding_shift = false
	if Input.is_action_just_released("RMB"):
		EventBus.current_state = EventBus.state.PLAY
