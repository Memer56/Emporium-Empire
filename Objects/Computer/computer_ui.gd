extends Control

const HOTBAR_ICON = preload("res://Objects/Computer/hotbar_icon.tscn")

@export var icons : Array
@onready var win_icon_background = $Desktop/Hotbar/WindowsIcon/WinIconBackground
@export var supplies : Node
@export var idk : Node
@onready var rendering_layer = $Desktop/RenderingLayer
@onready var desktop = $Desktop


var is_grabbing_program := false
var grabbed_program
var last_clicked_program
var offset
var calculated_offset := false
var number : int = 1


func _physics_process(_delta):
	handle_mouse_input()
	if is_grabbing_program:
		grabbed_program.global_position = get_global_mouse_position() + offset

func toggle_self():
	if visible:
		hide()
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif not visible:
		show()
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_computer_prog_icon_icon_clicked(program_name):
	var program_to_launch
	var index : int
	match program_name:
		"Supplies":
			index = 0
			program_to_launch = supplies
		"Idk":
			index = 1
			program_to_launch = idk
	
	if !program_to_launch.visible:
		program_to_launch.show()
		load_icon_to_hotbar(program_name, icons[index])

func load_icon_to_hotbar(program_name, icon_to_load):
	var texture = icon_to_load
	var icon = HOTBAR_ICON.instantiate()
	get_node("Desktop/Hotbar/HBoxContainer").add_child(icon)
	icon.load_icon(texture)
	icon.name = program_name

func remove_icon_from_hotbar():
	var icon = get_node("Desktop/Hotbar/HBoxContainer/" + last_clicked_program)
	if icon != null:
		icon.queue_free()


func _on_windows_icon_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if !win_icon_background.visible:
				win_icon_background.show()


func _on_windows_close_btn_pressed():
	toggle_self()
	win_icon_background.hide()


func _on_close_pressed():
	match last_clicked_program:
		"Supplies":
			supplies.hide()
		"Idk":
			idk.hide()
	remove_icon_from_hotbar()


func _on_supplies_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var clicked_panel = get_clicked_panel(supplies, event.global_position)
			get_clicked_panel(supplies, event.global_position)
			if clicked_panel:
				var panels_to_disable = [idk]
				toggle_panel_mouse_filter(panels_to_disable, supplies)
				set_needed_variables("Supplies", supplies)
				reparent_and_reconnect_node_signals(supplies, "gui_input", _on_supplies_gui_input)

func _on_idk_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var clicked_panel = get_clicked_panel(idk, event.global_position)
			get_clicked_panel(idk, event.global_position)
			if clicked_panel:
				var panels_to_disable = [supplies]
				toggle_panel_mouse_filter(panels_to_disable, idk)
				set_needed_variables("Idk", idk)
				reparent_and_reconnect_node_signals(idk, "gui_input", _on_idk_gui_input)

func get_clicked_panel(panel : Panel, mouse_pos : Vector2):
	if panel.get_rect().has_point(mouse_pos):
		return panel
	return null

func toggle_panel_mouse_filter(panels_to_disable : Array, panel_to_enable : Panel):
	for panel in panels_to_disable:
		if panel.mouse_filter == MOUSE_FILTER_STOP:
			panel.mouse_filter = MOUSE_FILTER_IGNORE
	panel_to_enable.mouse_filter = Control.MOUSE_FILTER_STOP

func set_needed_variables(program_name : String, node : Node):
	grabbed_program = node
	last_clicked_program = program_name

func handle_mouse_input():
	if grabbed_program:
		if Input.is_action_pressed("LMB"):
			is_grabbing_program = true
			if !calculated_offset:
				offset = grabbed_program.global_position - get_global_mouse_position()
				calculated_offset = true
		else:
			is_grabbing_program = false
			calculated_offset = false
			grabbed_program = null

func reparent_and_reconnect_node_signals(node : Node, signal_name, callable):
	if node.get_parent() == desktop:
		desktop.remove_child(node)
		rendering_layer.add_child(node)
	else:
		rendering_layer.remove_child(node)
		desktop.add_child(node)
	
	if node.is_connected("gui_input", callable):
		return
	else:
		node.connect(signal_name, callable)
