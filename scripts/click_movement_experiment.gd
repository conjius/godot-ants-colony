extends Node2D

onready var nav : Navigation2D = $Navigation2D
onready var ant : Node2D = $Ant
onready var pathing = $PathingQueue


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			pathing.set_path(get_global_mouse_position())

