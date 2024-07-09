extends Panel

const BASKET_ITEM = preload("res://Objects/Computer/basket_item.tscn")

@export var images : Array
@export var basket : Array
@onready var grid_container = $BasketContainer/GridContainer
@onready var total_price = $Panel/TotalPrice
@onready var order_button = $OrderButton

var total_price_num : int
var minimum_total : int = 0
var van

func _ready():
	var v = get_tree().get_nodes_in_group("van")
	if v:
		van = v

func _on_supplies_button_button_was_pressed(item_name, price):
	var basket_item
	var basket_item_name
	var image_index
	match item_name:
		"Baguette":
			basket_item_name = "Baguette"
			image_index = images[0]
		"Peanut Butter Jar":
			basket_item_name = "Peanut Butter Jar"
			image_index = images[1]
	
	basket_item = BASKET_ITEM.instantiate()
	get_node("BasketContainer/GridContainer").add_child(basket_item)
	basket_item.set_info(basket_item_name, image_index, price)
	update_total_price(price, true)
	add_to_basket(basket_item_name)
	minimum_total += price

func add_to_basket(item_name : String):
	var item_info : Array
	var quantity := 1
	item_info.append(item_name)
	item_info.append(quantity)
	basket.append(item_info)
	print("BASKET: ", basket)

func update_total_price(price : int, add : bool):
	if add:
		total_price_num += price
	elif !add:
		total_price_num -= price
		if total_price_num <= minimum_total:
			total_price_num = minimum_total
			total_price.text = str(total_price_num)

	total_price.text = str(total_price_num)

func increase_item_quantity(item_name : String):
	var item_qty = find_and_edit_item_info_in_basket(item_name, false, false, 0)
	var new_qty = item_qty + 1
	find_and_edit_item_info_in_basket(item_name, false, true, new_qty)

func decrease_item_quantity(item_name : String):
	var item_qty = find_and_edit_item_info_in_basket(item_name, false, false, 0)
	var new_qty = item_qty - 1
	if new_qty < 1:
		new_qty = 1
	find_and_edit_item_info_in_basket(item_name, false, true, new_qty)

func find_and_edit_item_info_in_basket(item_name : String, is_finding_name : bool, is_modifying_qty : bool, new_qty : int):
	for index in basket.size():
		var item_info = basket[index]
		if is_finding_name:
			var items_name = item_info[0]
			if items_name == item_name:
				print("item name: ", items_name)
				return items_name
		elif is_modifying_qty:
			var items_name = item_info[0]
			if items_name == item_name:
				item_info.remove_at(1)
				item_info.insert(1, new_qty)
				print("QTY modified basket: ", basket)
		else:
			var items_name = item_info[0]
			if items_name == item_name:
				var items_qty = item_info[1]
				return items_qty

func remove_all_duplicate_items_from_array(item_name : String):
	var n = basket.count(item_name)
	for items in n:
		basket.erase(item_name)

func reset_basket():
	total_price_num = 0
	minimum_total = 0
	total_price.text = str(total_price_num)
	get_tree().call_group("basket_item", "remove_self")

func _on_order_button_pressed():
	var delivery_van = van[0]
	order_button.disabled = true
	print("og basket: ", basket)
	delivery_van.trigger_events(basket)
	await get_tree().create_timer(20).timeout
	order_button.disabled = false
	basket.clear()
	reset_basket()
