extends CharacterBody3D

@onready var mesh = $Knight/Rig/Skeleton3D
@onready var ray_cast = $RayCast3D
@onready var animation_player = $Knight/AnimationPlayer
@onready var navigation_agent = $NavigationAgent3D
@export var freeze : bool
@onready var item_picker_ray = $ItemPickerRay
@onready var timer = $Timer
@onready var label_3d = $Label3D
@onready var decision_timeout = $DecisionTimeout
@onready var right_hand_pos = $RightHandPos

var speed := 5.0
var gravity = 200
var next_location
var target_position
var spawn_position
var item_positions := []
var picked_items_array := []
var checkout_objects := []
var picked_item_prices := []
var is_paying_for_item := false
var num_of_items_to_get : int
var current_num_of_items_held : int
var attempted_to_grab_item : int
var destination_reached := false
var can_drop_items := false
var queue_pos_search := false
var chosen_checkout = null


func _ready():
	if freeze:
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	check_raycast_collides_with_item()
	if target_position and !is_paying_for_item:
		item_picker_ray.set_target_position(item_picker_ray.to_local(target_position))
	else:
		item_picker_ray.set_target_position(Vector3(0, 1, 0))
	
	search_for_queue_position()
	move_to_target(delta)
	
	if ray_cast.is_colliding() and is_on_floor():
		jump()
	
	apply_gravity(delta)
	
func freeze_npc_movement():
	set_physics_process(false)
	navigation_agent.set_velocity(Vector3.ZERO)
	await get_tree().create_timer(0.7).timeout
	set_physics_process(true)


func move_to_target(delta):
	var current_location = global_position
	await get_tree().process_frame
	next_location = navigation_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * speed
	mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(new_velocity.x, new_velocity.z) - rotation.y, delta * 10)
	ray_cast.rotation.y = mesh.rotation.y
	
	navigation_agent.set_velocity(new_velocity)

func update_target_location(target_location):
	var target_location_x = target_location.x
	var target_location_z = target_location.z
	navigation_agent.target_position.x = target_location_x
	navigation_agent.target_position.z = target_location_z

func jump():
	velocity.y += 10

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

func _on_navigation_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, 0.25)
	if velocity:
		animation_player.play("Walking_A")
	elif velocity == Vector3.ZERO:
		animation_player.play("Idle")
	move_and_slide()

############################## AI Decision Logic Below ###########################################

func _on_timer_timeout():
	choose_next_target()

func choose_next_target():
	var n : int
	#n = randi_range(1, 6)
	n = 1
	if n >= 1 and n <= 2:
		if EventBus.is_shop_open:
			choose_num_of_items_to_get()
			decision_timeout.start(20)
			await get_tree().create_timer(0.5).timeout
			choose_item()
		else:
			label_3d.show()
			label_3d.text = str("The Shop is Closed")
	if n > 2 and n < 7:
		update_target_location(Vector3(0, 0, 0))
		timer.start(20)

func choose_num_of_items_to_get():
	var n = randi_range(1, 3)
	num_of_items_to_get = n

func choose_item():
	destination_reached = false
	disable_item_raycast()
	item_positions.clear()
	if EventBus.num_of_items_in_world > 0:
		for items in get_tree().get_nodes_in_group("items"):
			var positions = items.global_position
			item_positions.append(positions)
			target_position = item_positions.pick_random()
			update_target_location(target_position)
	else:
		push_error("No items have been found")


func _on_navigation_agent_3d_target_reached():
	if !is_paying_for_item:
		destination_reached = true
		#item_picker_ray.set_target_position(item_picker_ray.to_local(target_position))
		enable_item_raycast()
		item_positions.clear()
	else:
		disable_item_raycast()
		num_of_items_to_get = 0
		update_target_location(global_position)
		mesh.rotation.y = EventBus.player_pos.y
		await get_tree().create_timer(0.2).timeout
		if can_drop_items:
			EventBus.send_picked_item_data.emit(picked_items_array, spawn_position)
			#Allows checkout to obtain the below variables value
			await get_tree().create_timer(0.2).timeout
			picked_items_array.clear()
	
	if queue_pos_search:
		queue_pos_search = false


func check_raycast_collides_with_item():
	var collider = item_picker_ray.get_collider()
	if collider is RigidBody3D:
		if collider.is_in_group("items"):
			if item_picker_ray.is_colliding():
				var picked_items = []
				var id = collider.id
				var price = collider.item_price
				picked_items.append(id)
				picked_items.append(price)
				picked_items_array.append(picked_items)
				picked_item_prices.append(collider.item_price)
				collider.queue_free()
				current_num_of_items_held += 1
				await get_tree().create_timer(0.3).timeout
				if current_num_of_items_held >= num_of_items_to_get:
					is_paying_for_item = true
					go_to_checkout_and_unload_items()
					item_picker_ray.enabled = false
				else:
					choose_item()
	
	elif collider == null and destination_reached == true:
		if target_position:
			if global_position.direction_to(target_position) <= Vector3(0.4, 0, 0.4):
				choose_item()

func go_to_checkout_and_unload_items():
	destination_reached = false
	decision_timeout.stop()
	if EventBus.checkouts_exist_in_scene:
		navigation_agent.target_desired_distance = 2.4
		for checkouts in get_tree().get_nodes_in_group("checkout"):
			# rather than base which checkpoint is chosen from its position just identify which checkout object it is
			# then you can access vital functions in checkout script
			checkout_objects.append(checkouts)
			chosen_checkout = checkout_objects.pick_random()
			spawn_position = checkouts.marker_pos
			if chosen_checkout.queue_pos_check_array.has(true):
				find_correct_queue_pos()
			else:
				go_to_checkout_and_unload_items()

	else:
		label_3d.show()
		label_3d.text = "LMAO I'm Stealing"
		picked_items_array.clear()
		push_error("No checkouts found in scene")

func find_correct_queue_pos():
	var index = chosen_checkout.queue_pos_check_array.find(true)
	match index:
		0:
			target_position = chosen_checkout.queue_pos[0]
		1:
			target_position = chosen_checkout.queue_pos[1]
	
	if target_position:
		queue_pos_search = true

func search_for_queue_position():
	if queue_pos_search:
		update_target_location(target_position)

func _input(event):
	if Input.is_action_just_pressed("Test"):
		set_physics_process(true)
		timer.start()

func disable_item_raycast():
	item_picker_ray.set_collision_mask_value(4, false)

func enable_item_raycast():
	item_picker_ray.set_collision_mask_value(4, true)


func _on_decision_timeout():
	attempted_to_grab_item += 1
	if attempted_to_grab_item == 4 and current_num_of_items_held == 0:
		attempted_to_grab_item = 0
		item_positions.clear()
		print("Decision timed out, choosing next target")
		choose_next_target()
	elif attempted_to_grab_item == 4 and current_num_of_items_held > 0:
		print("Decision timed out, going to checkout")
		go_to_checkout_and_unload_items()

func received_receipt():
	label_3d.show()
	label_3d.text = "Thank You!!!"
	await get_tree().create_timer(1.4).timeout
	label_3d.hide()
	checkout_objects.clear()
	update_target_location(Vector3(0, 0, 0))


func _on_area_3d_body_entered(body):
	if body.get_collision_layer() == 2048:
		EventBus.player_drop_object.emit()
		var tween = get_tree().create_tween()
		var start_pos = body.global_position
		tween.tween_property(body, "global_position", right_hand_pos.global_position, 1)
		body.despawn()
		received_receipt()
