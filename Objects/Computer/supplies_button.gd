extends TextureButton

#https://icons8.com/icon/44049/shop

signal button_was_pressed(item_name : String, price : int)

@export var image : Texture2D
@export var item_name : String
@export var price : int
@onready var name_tag = $NameTag
@onready var price_tag = $PriceTag

func _ready():
	texture_normal = image
	name_tag.text = item_name
	price_tag.text = str(price)


func _on_pressed():
	print("Button was pressed down")
	button_was_pressed.emit(item_name, price)
