extends StaticBody3D

var total_calculated = false
@export var id = 4


func _on_cash_checker_body_entered(body):
	if body.get_collision_layer() == 8:
		body.despawn()
