class_name InputManager
extends Control

const TaskType = preload("res://scripts/common/TaskType.gd")

onready var world_camera = $"../WorldCamera"
onready var world_map = $"../WorldMap"
onready var task_manager = $"../TaskManager"

onready var click_position

onready var cur_mouse_hover_tile_coordinates: Vector2
onready var prev_mouse_hover_tile_coordinates: Vector2 = Vector2.ZERO

func _process(delta: float):
	cur_mouse_hover_tile_coordinates = world_map.world_position_to_tile_coordinates(get_global_mouse_position())
	world_map.unmark_on_hover_tile(prev_mouse_hover_tile_coordinates)
	world_map.mark_on_hover_tile(cur_mouse_hover_tile_coordinates)
	prev_mouse_hover_tile_coordinates = cur_mouse_hover_tile_coordinates

func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CONFINED else Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_WHEEL_UP:
				world_camera.zoom_in_towards_mouse_position(get_global_mouse_position())
			BUTTON_WHEEL_DOWN:
				world_camera.zoom_out()
			BUTTON_MIDDLE: 
				world_camera.handle_panning_input(event.is_pressed(), get_global_mouse_position())
			BUTTON_RIGHT:
				handle_right_mouse_click(event.is_pressed(), get_global_mouse_position())

func handle_right_mouse_click(is_pressed: bool, mouse_position: Vector2):
	var tile_coordinates = world_map.world_position_to_tile_coordinates(mouse_position)
	if is_pressed and world_map.is_tile_interactable(tile_coordinates):
		var task_world_position = world_map.tile_coordinates_to_world_position(tile_coordinates)
		var task_type = world_map.get_tile_task_type(tile_coordinates)
		world_map.mark_task_on_map(tile_coordinates)
		task_manager.add_task(task_world_position, task_type)                                                                                                                                                                                                                                                                                
