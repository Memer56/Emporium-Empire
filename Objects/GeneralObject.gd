extends Node3D

@onready var area_3d = $Area3D
@onready var checker_collision : CollisionShape3D = $NpcChecker/CollisionShape3D
@onready var mesh_1 = $mesh
@onready var cube_020 = $mesh/Cube_020
@onready var cube_022 = $mesh/Cube_022
@onready var cube_023 = $mesh/Cube_023
@onready var cube_024 = $mesh/Cube_024
@onready var plane_001 = $mesh/Plane_001
@onready var plane_003 = $mesh/Plane_003
@onready var audio_stream_player = $AudioStreamPlayer3D
@onready var cash_register = $cashregister
@onready var label = $Label3D
@onready var animation_player = $AnimationPlayer

var green = Color("40ea0074")
var red = Color("e8000074")
var placement_mode = false
var item_prices = []
var num_of_items : int
var num_of_actual_items : int
var coin_tray_open  = false
var total = 0

func _ready():
	placement_mode = true
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	EventBus.object_white.connect(object_white)
	EventBus.clicked_on_cash_register.connect(toggle_coin_tray)
	set_material_colour_green()


func _on_body_entered(_body):
	BuildManager.able_to_build = false
	set_material_colour_red()


func _on_body_exited(_body):
	BuildManager.able_to_build = true
	set_material_colour_green()

func set_material_colour_green():
	mesh_1.set("instance_shader_parameters/colour", Color(green))
	cube_020.set("instance_shader_parameters/colour", Color(green))
	cube_022.set("instance_shader_parameters/colour", Color(green))
	cube_023.set("instance_shader_parameters/colour", Color(green))
	cube_024.set("instance_shader_parameters/colour", Color(green))
	plane_001.set("instance_shader_parameters/colour", Color(green))
	plane_003.set("instance_shader_parameters/colour", Color(green))

func set_material_colour_red():
	mesh_1.set("instance_shader_parameters/colour", Color(red))
	cube_020.set("instance_shader_parameters/colour", Color(red))
	cube_022.set("instance_shader_parameters/colour", Color(red))
	cube_023.set("instance_shader_parameters/colour", Color(red))
	cube_024.set("instance_shader_parameters/colour", Color(red))
	plane_001.set("instance_shader_parameters/colour", Color(red))
	plane_003.set("instance_shader_parameters/colour", Color(red))


func object_white():
	checker_collision.set_deferred("disabled", false)
	cash_register.visible = true
	label.visible = true
	mesh_1.material_override = null
	cube_020.material_override = null
	cube_022.material_override = null
	cube_023.material_override = null
	cube_024.material_override = null
	plane_001.material_override = null
	plane_003.material_override = null


func _on_npc_checker_body_entered(body):
	if body.get_collision_layer() == 4:
		item_prices = body.picked_item_prices
		num_of_items = body.current_num_of_items_held
		await get_tree().create_timer(0.2).timeout
		body.current_num_of_items_held = 0
	if body.get_collision_layer() == 8:
		num_of_actual_items += 1
		await get_tree().create_timer(0.5).timeout
		checker_collision.set_deferred("disabled", true)


func _on_scanner_body_entered(body):
	if body.get_collision_layer() == 8:
		num_of_actual_items -= 1
		audio_stream_player.play()
		body.despawn()
		if num_of_actual_items == 0:
			calculate_total()

func calculate_total():
	checker_collision.disabled = false
	for value in item_prices:
		total += value
		display_total()
		print("Total Price: ", total)

func display_total():
	label.text = str(total)

func toggle_coin_tray():
	if total:
		coin_tray_open = not coin_tray_open
		if coin_tray_open:
			animation_player.play("CoinTray")
			EventBus.payed_for_items.emit()
		else:
			animation_player.play_backwards("CoinTray")
			total = 0
			num_of_actual_items = 0
			display_total()
