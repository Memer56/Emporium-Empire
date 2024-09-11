extends Control

@onready var label: Label = $Panel/BG/Label
@onready var add_or_subtract_value: Label = $Panel/BG/AddOrSubtractValue
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var green = Color("00fb00")
var red = Color.RED


func _ready() -> void:
	EventBus.update_money_counter.connect(update_counter)
	label.text = str(EventBus.money)

func update_counter(new_value : int, add_subtract : String):
	if add_subtract == "add":
		EventBus.money += new_value
		add_or_subtract_value.set("theme_override_colors/font_color", green)
		add_or_subtract_value.text = "+" + str(new_value)
		animation_player.play("Add")
		label.text = str(EventBus.money)
	elif add_subtract == "subtract":
		if new_value <= EventBus.money:
			EventBus.money -= new_value
			add_or_subtract_value.set("theme_override_colors/font_color", red)
			add_or_subtract_value.text = "-" + str(new_value)
			animation_player.play("Subtract")
			label.text = str(EventBus.money)
	else:
		# This is here to update the counter when the game was loaded from a save file
		label.text = str(EventBus.money)
