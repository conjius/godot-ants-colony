extends Node2D

onready var queue : Array = []

func set_path(position : Vector2):
	queue.append(position)
	

