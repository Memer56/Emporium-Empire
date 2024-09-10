extends CharacterBody3D

@onready var navigation_agent = $NavigationAgent3D
@onready var mesh = $"Root Scene/RootNode/AnimalArmature/Skeleton3D"
@onready var ray_cast = $"Root Scene/RootNode/AnimalArmature/Skeleton3D/Fox/RayCast3D"
@onready var animation_player = $"Root Scene/AnimationPlayer"
@onready var collision_shape = $CollisionShape3D
@export var freeze : bool
@onready var timer = $Timer


var next_location
var speed := 5.0
var gravity = 200
var nav_mesh


func _ready():
	nav_mesh = get_node("../HouseNavMesh")
	if freeze:
		set_physics_process(false)
	else:
		timer.start()

func _physics_process(delta):
	if ray_cast.is_colliding() and is_on_floor():
		jump()
	
	move_to_target(delta)
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
	mesh.rotation.z = lerp_angle(mesh.rotation.z, atan2(new_velocity.x, new_velocity.z) - rotation.z, delta * 10)
	collision_shape.rotation.y = lerp_angle(collision_shape.rotation.y, atan2(new_velocity.x, new_velocity.z) - rotation.y, delta * 10)
	
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
		animation_player.play("Walk")
		animation_player.speed_scale = 2
	elif velocity == Vector3.ZERO:
		animation_player.play("Idle")
		animation_player.speed_scale = 1
	move_and_slide()

############################# Location Decision Logic Below ################################

func should_fox_move():
	var num = randi_range(1, 10)
	if num >= 1 and num <= 4:
		choose_next_target_location()
	elif num >= 5 and num <= 10:
		timer.start()

func choose_next_target_location():
	var random_x_value = randf_range(-4.0, 4.0)
	var random_y_value = randf_range(-4.0, 4.0)
	var target_location = Vector3(nav_mesh.position.x + random_x_value, 0, nav_mesh.position.z + random_y_value)
	update_target_location(target_location)


func _on_timer_timeout():
	should_fox_move()
