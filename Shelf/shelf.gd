extends StaticBody3D

@onready var area_3d = $Area3D
@onready var collision_shape = $Area3D/CollisionShape3D
@onready var mesh_1 = $mesh

var green = Color("40ea0074")
var red = Color("e8000074")
var placement_mode = false

func _ready():
	placement_mode = true
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	EventBus.object_white.connect(object_white)
	set_material_colour_green()

func _on_body_entered(body):
	BuildManager.able_to_build = false
	set_material_colour_red()


func _on_body_exited(body):
	BuildManager.able_to_build = true
	set_material_colour_green()

func set_material_colour_green():
	mesh_1.set("instance_shader_parameters/colour", Color(green))

func set_material_colour_red():
	mesh_1.set("instance_shader_parameters/colour", Color(red))


func object_white():
	mesh_1.material_override = null
