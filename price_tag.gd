extends StaticBody3D

@onready var label = $PriceTagMesh/Label3D
@onready var price_tag_edit = $PriceTagEdit
@export var id = 2

func show_price_tag_editor():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	price_tag_edit.show()

func set_price(new_price : float):
	if new_price is float:
		label.text = str(new_price)
	else:
		label.text = str("£0")

func _on_area_3d_body_entered(body):
	if body.get_collision_layer() == 8:
		body.set_own_price(float(label.text))


func _on_area_3d_body_exited(body):
	if body.get_collision_layer() == 8:
		body.set_own_price(0)
