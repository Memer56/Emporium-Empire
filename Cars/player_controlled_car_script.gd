extends VehicleBody3D

const MAX_STEER = 0.8
const ENGINE_POWER = 300

var receive_player_input := false
var is_in_car := false
var player
var horsepower = 100
var steer_limit = deg_to_rad(30)

@onready var wheel_front_right = $FrontRight/wheel_frontRight
@onready var wheel_front_left = $FrontLeft/wheel_frontLeft
@onready var wheel_back_left = $BackRight/wheel_backRight
@onready var wheel_back_right = $BackLeft/wheel_backLeft
@onready var camera = $Camera3D
@onready var exit_point = $body/ExitPoint
@onready var driver_seat = $body/DriverSeat

func _ready():
	wheel_front_right.set_scale(Vector3(2.5, 2.5, 2.5))
	wheel_front_left.set_scale(Vector3(2.5, 2.5, 2.5))
	wheel_back_right.set_scale(Vector3(2.5, 2.5, 2.5))
	wheel_back_left.set_scale(Vector3(2.5, 2.5, 2.5))

func _physics_process(delta):
	if is_in_car:
		steering = move_toward(steering, Input.get_axis("Left", "Right") * MAX_STEER, delta * 2.5)
		engine_force = Input.get_axis("Back", "Forward") * ENGINE_POWER


func _on_area_3d_body_entered(body):
	if body.get_collision_layer() == 1:
		receive_player_input = true
		if player == null:
			player = body


func _on_area_3d_body_exited(body):
	if body.get_collision_layer() == 1:
		receive_player_input = false

func _input(event):
	if Input.is_action_just_pressed("Interact") and receive_player_input:
		is_in_car = true
		camera.current = true
		player.global_position = driver_seat.global_position
		player.disable_self()
	if Input.is_action_just_pressed("Jump") and is_in_car:
		is_in_car = false
		camera.current = false
		player.global_position = exit_point.global_position
		player.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
		player.enable_self()
