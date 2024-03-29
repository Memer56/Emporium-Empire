extends Control

@onready var border = $Border
@onready var buttons = $Buttons
@onready var shelf : PackedScene = ResourceLoader.load("res://Shelf/shelf.tscn")
@onready var objects_list = $ObjectsList
var build_mode_colour = Color("91e900")
var destroy_mode_colour = Color("d20007")
var adjust_mode_color = Color.YELLOW
var border_visible : bool = false
var recieved_signal : bool = false

func _ready():
	EventBus.image_button_pressed.connect(determine_which_button_was_pressed)

func _process(delta):
	if EventBus.current_state != EventBus.state.PLAY:
		border.show()
	elif EventBus.current_state == EventBus.state.PLAY and !recieved_signal:
		border.hide()

func manually_toggle_border():
	border_visible = not border_visible
	
	if border_visible:
		border.show()
		change_border_colour(build_mode_colour)
	else:
		border.hide()

func _on_add_items_pressed():
	objects_list.show()

func _on_remove_items_pressed():
	EventBus.current_state = EventBus.state.DESTROYING
	change_border_colour(destroy_mode_colour)
	toggle_self()

func _on_quit_mode_pressed():
	EventBus.current_state = EventBus.state.PLAY
	recieved_signal = false

func change_border_colour(colour : Color):
	var border_colour = border.get_theme_stylebox("panel")
	border_colour.border_color = colour
	border.remove_theme_stylebox_override("panel")
	border.add_theme_stylebox_override("panel", border_colour)

func _input(event):
	if Input.is_action_just_pressed("ShowTopUIButtons"):
		# Maybe change this to be animated
		toggle_self()

func toggle_self():
	buttons.visible = not buttons.visible
	
	if buttons.visible:
		buttons.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
	else:
		buttons.hide()
		await get_tree().create_timer(0.2).timeout
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false

func determine_which_button_was_pressed(object_name : String):
	toggle_self()
	match object_name:
		"Checkout":
			add_checkout()
		"Shelf":
			add_shelf()
		"Small Wall":
			add_small_wall()
		"Medium Wall":
			add_medium_wall()
		"Large Wall":
			add_large_wall()

func add_shelf():
	BuildManager.spawn_shelf()
	hide_ui()

func add_small_wall():
	BuildManager.selected_build_object = true
	BuildManager.spawn_small_wall()
	hide_ui()

func add_medium_wall():
	BuildManager.selected_build_object = true
	BuildManager.spawn_medium_wall()
	hide_ui()


func add_large_wall():
	BuildManager.selected_build_object = true
	BuildManager.spawn_large_wall()
	hide_ui()


func add_checkout():
	BuildManager.spawn_checkout()
	hide_ui()


func hide_ui():
	change_border_colour(build_mode_colour)
	toggle_self()
	# For some reason toggle_self() doen't hide the buttons ://////////
	buttons.hide()
	objects_list.hide()



func _on_player_show_border(true_or_false):
	manually_toggle_border()
	recieved_signal = true_or_false
