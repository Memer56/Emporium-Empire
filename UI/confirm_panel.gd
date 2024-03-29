extends Control

@export_multiline var body_text : String
@export var confirm_button_text : String
@export var deny_button_text : String
@onready var body_text_label = $Panel/BodyTextLabel
@onready var confirm_button_label = $Panel/ConfirmButton/ConfirmButtonLabel
@onready var deny_button_label = $Panel/DenyButton/DenyButtonLabel

func _ready():
	body_text_label.text = body_text
	confirm_button_label.text = confirm_button_text
	deny_button_label.text = deny_button_text
