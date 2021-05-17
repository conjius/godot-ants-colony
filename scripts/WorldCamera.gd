class_name WorldCamera
extends Camera2D

const MAP_SCROLLING_SPEED = 1500
const SCREEN_EDGE_SCROLL_PADDING = 5
const ZOOM_SPEED = 0.03
const MIN_ZOOM = 0.4
const MAX_ZOOM = 1

onready var mouse_position
onready var scrolling_direction = Vector2(0,0)
onready var is_scrolling = false
onready var is_panning = false
onready var pan_start_location
onready var target_location


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(delta):
	pan_map()
	screen_edge_scroll_map(delta)
	

func pan_map():
	if is_panning:
		self.position -= get_global_mouse_position() - pan_start_location
	

func screen_edge_scroll_map(delta: float):
	mouse_position = get_viewport().get_mouse_position()
	if mouse_position.x < SCREEN_EDGE_SCROLL_PADDING: # left screen edge
		is_scrolling = true
		scrolling_direction.x -= 1
	if mouse_position.y < SCREEN_EDGE_SCROLL_PADDING: # top screen edge
		is_scrolling = true
		scrolling_direction.y -= 1
	if mouse_position.x > get_viewport_rect().size.x - SCREEN_EDGE_SCROLL_PADDING: # right screen edge
		is_scrolling = true
		scrolling_direction.x += 1
	if mouse_position.y > get_viewport_rect().size.y - SCREEN_EDGE_SCROLL_PADDING: # bottom screen edge
		is_scrolling = true
		scrolling_direction.y += 1
	if is_scrolling == false:
		scrolling_direction = Vector2(0,0)
	scrolling_direction = scrolling_direction.normalized()
	
	if is_scrolling && !is_panning:
		self.position += (scrolling_direction * delta * MAP_SCROLLING_SPEED * zoom.x) # the more we zoom out, the faster the scrolling should be
		scrolling_direction = Vector2.ZERO
		is_scrolling = false

func zoom_in():
	zoom -= Vector2(ZOOM_SPEED, ZOOM_SPEED)
	limit_zoom()

func zoom_out():
	zoom += Vector2(ZOOM_SPEED, ZOOM_SPEED)
	limit_zoom()

func limit_zoom():
	zoom.x = clamp(zoom.x, MIN_ZOOM, MAX_ZOOM)
	zoom.y = clamp(zoom.y, MIN_ZOOM, MAX_ZOOM)
	
func handle_panning_input(is_starting_to_pan: bool, event_mouse_position: Vector2):
	is_panning = is_starting_to_pan
	pan_start_location = event_mouse_position
	
