extends Control

@onready var texture_rect = $Button/TextureRect
@onready var price_tag = $Button/PriceTag
@onready var object_name = $Button/ObjectName
@export var Price : int
@export var Name : String
@export var Object_Image : Texture

var new_colour : Color
var default_colour := Color.WHITE
var colour_was_chosen := false

func _ready():
	price_tag.text = str(Price)
	object_name.text = str(Name)
	texture_rect.texture = Object_Image

func remove_self():
	queue_free()


func _on_button_pressed():
	if colour_was_chosen:
		EventBus.image_button_pressed.emit(Name, new_colour)
		colour_was_chosen = false
	else:
		EventBus.image_button_pressed.emit(Name, default_colour)


func _on_color_picker_button_color_changed(color):
	colour_was_chosen = true
	new_colour = color
