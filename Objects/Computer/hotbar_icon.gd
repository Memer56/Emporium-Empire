extends Control

@onready var texture_rect = $TextureRect

func load_icon(texture_icon):
	texture_rect.texture = texture_icon
