class_name Task
extends Node2D

const TaskType = preload("res://scripts/common/TaskType.gd")

onready var task_type setget set_task_type, get_task_type
onready var task_id

func init(new_location : Vector2 , new_task_type: int, new_task_id: int) -> Task:
	self.task_type = new_task_type
	self.position = new_location
	self.task_id = new_task_id
	return self

func _ready():
	add_to_group("tasks")

func set_task_type(new_task_type):
	task_type = new_task_type
	
func get_task_type():
	return task_type
