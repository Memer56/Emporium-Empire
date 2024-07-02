extends Node3D

const BARBARIAN_NPC = preload("res://NPCs/barbarian_npc.tscn")
const KNIGHT_NPC = preload("res://NPCs/knight_npc.tscn")

var is_spawning_npc := false
@onready var timer = $Timer

func _ready():
	add_points_to_array()

func add_points_to_array():
	for points in get_tree().get_nodes_in_group("spawnpoint"):
		EventBus.npc_spawn_points.append(points.global_position)


func _on_spawn_point_body_entered(body):
	if body.get_collision_layer() == 4 and !is_spawning_npc:
		body.despawn()

func _on_spawn_point_body_exited(_body):
	is_spawning_npc = false


func _on_timer_timeout():
	spawn_npc()

func spawn_npc():
	var npc
	var num = randi_range(1, 2)
	is_spawning_npc = true
	match num:
		1:
			npc = KNIGHT_NPC.instantiate()
		2:
			npc = BARBARIAN_NPC.instantiate()
	
	if npc != null:
		add_child(npc)
		var npc_position = EventBus.npc_spawn_points.pick_random()
		npc.global_position = npc_position

func _input(event):
	if Input.is_action_just_pressed("Test"):
		timer.start()
