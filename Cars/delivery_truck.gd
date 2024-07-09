extends Path3D

const CARDBOARD_BOX = preload("res://Objects/cardboard_box_1.tscn")

@onready var animation_player = $AnimationPlayer
@onready var path_follow_3d = $PathFollow3D
@onready var body = $Body
@onready var spawnpoint = $Body/Spawnpoint
@onready var timer = $Timer

var num_of_boxes_spawned := 0
var max_num_of_possible_boxes := 0
var offset = Vector3(0, 0, 0)

func trigger_events(basket : Array):
	animation_player.play("anim")
	await get_tree().create_timer(18).timeout
	seperate_item_info_from_basket(basket)
	timer.start()

func seperate_item_info_from_basket(basket : Array):
	num_of_boxes_spawned = basket.size()
	for index in basket.size():
		var item = basket[index]
		add_to_new_basket(item)

func add_to_new_basket(item):
	#await get_tree().create_timer(2).timeout
	var new_basket = item
	print("New basket: ", new_basket)
	spawn_box(new_basket)

func spawn_box(new_basket : Array):
	var box = CARDBOARD_BOX.instantiate()
	get_tree().root.add_child(box)
	box.global_position = spawnpoint.global_position + offset
	box.spawn_items(new_basket)
	offset.y += 2

func reset_pos():
	animation_player.play("RESET")
	offset.y = 0
	num_of_boxes_spawned = 0
	max_num_of_possible_boxes = 0


func _on_timer_timeout():
	reset_pos()
