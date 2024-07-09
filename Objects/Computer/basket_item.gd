extends Panel

@onready var quantity = $Quantity
@onready var item_tag = $ItemTag
@onready var texture = $Texture

var supplies
var price
var item_name

var item_quantity = 1

func _ready():
	quantity.text = str(item_quantity)
	supplies = get_parent().get_parent().get_parent()

func set_info(new_item_name, new_texture, new_price):
	item_name = new_item_name
	item_tag.text = item_name
	texture.texture = new_texture
	price = new_price


func _on_plus_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			item_quantity += 1
			quantity.text = str(item_quantity)
			supplies.update_total_price(price, true)
			supplies.increase_item_quantity(item_name)


func _on_minus_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			item_quantity -= 1
			quantity.text = str(item_quantity)
			supplies.update_total_price(price, false)
			if item_quantity < 1:
				item_quantity = 1
				quantity.text = str(item_quantity)
			else:
				supplies.decrease_item_quantity(item_name)


func _on_remove_pressed():
	var new_price = item_quantity * price
	supplies.minimum_total -= price
	supplies.remove_all_duplicate_items_from_array(item_name)
	supplies.update_total_price(new_price, false)
	remove_self()

func remove_self():
	queue_free()
