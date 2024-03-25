extends StaticBody3D

@onready var animation_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@export var id = 1

var door_open = false

func _ready():
	EventBus.toggle_door.connect(toggle_door)

func toggle_door():
	if !door_open:
		animation_player.play("ToggleDoor")
		door_open = true
	else:
		animation_player.play_backwards("ToggleDoor")
		door_open = false


func _on_area_3d_body_entered(body):
	if body.get_collision_layer() == 4:
		EventBus.freeze_npc.emit()
		toggle_door()

func toggle_collision():
	collision_shape.disabled = not collision_shape.disabled
	
	if collision_shape.disabled:
		collision_shape.disabled = true
	else:
		collision_shape.disabled = false
