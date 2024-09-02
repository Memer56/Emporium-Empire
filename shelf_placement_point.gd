extends Marker3D

@onready var area_3d: Area3D = $Area3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D

@export var is_free_of_item := true

var index : int

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_collision_layer() == 8:
		index = body.index
		body.is_on_point = true
		EventBus.last_item_placed_on_shelf = body.name
		EventBus.change_shelf_points_true_false_array_value.emit(index, true)

func remove_self():
	queue_free()
