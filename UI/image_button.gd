extends Control

@onready var texture_rect = $Button/TextureRect
@onready var price_tag = $Button/PriceTag
@onready var object_name = $Button/ObjectName
@export var Price : String
@export var Name : String


func _ready():
	price_tag.text = str(Price)
	object_name.text = str(Name)


func _on_button_pressed():
	EventBus.image_button_pressed.emit(Name)
