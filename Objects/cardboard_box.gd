extends RigidBody3D

const PEANUT_BUTTER_JAR = preload("res://Items/peanut_butter_jar.tscn")

@onready var box_mesh = $BoxMesh
@onready var open_box_nesh : ArrayMesh = preload("res://MeshFiles/open_box_mesh.tres")
@onready var collision_top = $CollisionTop

var opened = false

func _ready():
	spawn_items()

func spawn_items():
	var item = PEANUT_BUTTER_JAR.instantiate()
	get_tree().root.add_child.call_deferred(item)
	item.global_position = global_position

func open():
	box_mesh.mesh = open_box_nesh
	if !opened:
		box_mesh.position.y += 0.144
		box_mesh.position.z += 0.051
		collision_top.disabled = true
		opened = true

func despawn():
	queue_free()


func _on_timer_timeout():
	despawn()
