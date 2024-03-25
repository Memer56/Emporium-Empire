extends CharacterBody3D

signal show_border(true_or_false : bool)

@export var speed = 10.0
@export var max_speed = 15.0
@export var normal_speed = 10.0
@export var acceleration = 5.0
@export var mouse_sensitivity = 0.25
@export var air_speed = 8.0
@export var jumpforce = 5.0
@onready var head = $head
@onready var visual_body = $VisualBody
@onready var interaction = $head/Camera3D/Interaction
@onready var hand = $head/Camera3D/Hand
@onready var joint = $head/Camera3D/Generic6DOFJoint3D
@onready var static_body = $head/Camera3D/StaticBody3D
@onready var reticle = $CanvasLayer/Reticle
@onready var green_reticle = $CanvasLayer/GreenReticle
@onready var animation_player = $AnimationPlayer

var state
var gravity = 10
var direction = Vector3.ZERO
var picked_object
var pull_power = 10
var rotation_power = 0.1
var locked = false
var enable_build_pov = false
var upwards_force = 1.0
var positive_head_rotation_limit_x = 89
var negative_head_rotation_limit_x = -89
# Used if calling a function every frame is annoying
var delta_value = 0.01666666666667

enum {
	NORMAL,
	CUTSCENE,
	FLY
}

func _ready():
	state = NORMAL
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	visual_body.hide()
	CheatManager.change_state.connect(change_state)
	EventBus.remove_spawnable.connect(remove_spawnable)

func _physics_process(delta):
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), acceleration * delta)
	
	EventBus.player_pos = global_position
	change_reticle_colour()
	detect_interactable()
	build_pov(delta)
	match state:
		NORMAL:
			move_player(delta, direction)
		CUTSCENE:
			pass
		FLY:
			fly(delta, direction)
	
	move_and_slide()
	
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b - a) * pull_power)

func remove_spawnable():
	var collider = interaction.get_collider()
	if collider is StaticBody3D:
		if collider.is_in_group("spawnable"):
			collider.queue_free()
			EventBus.recalculate_nav_region.emit()

func change_reticle_colour():
	if interaction.get_collider() is RigidBody3D and picked_object == null:
		green_reticle.show()
	else:
		green_reticle.hide()

func detect_interactable():
	var collider = interaction.get_collider()
	if collider is StaticBody3D:
		if collider.is_in_group("interactable"):
			if Input.is_action_just_pressed("LMB"):
				if collider.id == 1:
					EventBus.toggle_door.emit()
				if collider.id == 4:
					EventBus.clicked_on_cash_register.emit()
			if Input.is_action_just_pressed("RMB"):
				if collider.id == 2:
					collider.show_price_tag_editor()
			green_reticle.show()
		else:
			green_reticle.hide()

func pick_object():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_object = collider
		joint.set_node_b(picked_object.get_path())
		reticle.hide()
		green_reticle.hide()

func drop_object():
	if picked_object != null:
		picked_object = null
		joint.set_node_b(joint.get_path())
		reticle.show()

func rotate_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			static_body.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			static_body.rotate_y(deg_to_rad(event.relative.x * rotation_power))

func move_player(delta, direction):
	if is_on_floor():
		if direction :
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		velocity.x = direction.x * air_speed
		velocity.z = direction.z * air_speed
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y += jumpforce
	
	apply_gravity(delta)

func fly(_delta, direction):
	if direction :
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if Input.is_action_pressed("Jump"):
		#for some reason this upwards force number has to be higher than the negative value, I'm so confused
		velocity.y = 2.0 * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	
	if Input.is_action_pressed("Shift"):
		velocity.y = -1.0 * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

func look_around(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(negative_head_rotation_limit_x), deg_to_rad(positive_head_rotation_limit_x))

func open_box():
	var collider = interaction.get_collider()
	if collider and collider is RigidBody3D:
		collider.open()

func _input(event):
	if !locked:
		look_around(event)
	
	if Input.is_action_just_pressed("LMB"):
		if picked_object == null:
			pick_object()
		elif picked_object != null:
			drop_object()
	
	if Input.is_action_pressed("RMB") and EventBus.current_state == EventBus.state.PLAY:
		locked = true
		rotate_object(event)
	if Input.is_action_just_released("RMB"):
		locked = false
	
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("Interact"):
		open_box()
	
	if Input.is_action_just_pressed("BuildMode"):
		toggle_build_pov_variable()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			hand.position.z += 0.2
			if hand.position.z >= -0.7:
				hand.position.z = -0.69744980335236
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			hand.position.z -= 0.2
			if hand.position.z <= -5.9:
				hand.position.z = -5.89744853973389

func change_state(new_state : int):
	state = new_state

func toggle_build_pov_variable():
	enable_build_pov = not enable_build_pov
	
	if enable_build_pov:
		enable_build_pov = true
		toggle_border(true)
	else:
		enable_build_pov = false
		toggle_border(false)

func build_pov(delta):
	if enable_build_pov:
		var acending_speed = 60
		velocity.y += acending_speed * delta
		locked = true
		animation_player.play("BuildPOV")
		positive_head_rotation_limit_x = -45
		await get_tree().create_timer(1).timeout
		state = FLY
		locked = false
		acending_speed = 0
	else:
		exit_build_pov()

func exit_build_pov():
	state = NORMAL
	positive_head_rotation_limit_x = 89
	animation_player.active = true
	animation_player.play("PreventAnnoyingAnim")

func toggle_border(true_or_false : bool):
	show_border.emit(true_or_false)

