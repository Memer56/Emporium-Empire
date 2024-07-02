extends Control

signal icon_clicked(program_name : String)

@onready var texture_button = $TextureButton
@export var icon : Texture
@export var program_name : String
@onready var label = $TextureButton/Label

func _ready():
	texture_button.texture_normal = icon
	label.text = program_name


func _on_texture_button_pressed():
	icon_clicked.emit(program_name)
