class_name TaskManager
extends Node

const TaskType = preload("res://scripts/common/TaskType.gd")
const NO_TASK_TASK_ID = 0

onready var ant_manager = $"../AntManager"

onready var no_task_task = Task.new().init(Vector2.ZERO, TaskType.NO_TASK, NO_TASK_TASK_ID)
onready var unassigned_tasks = {}
onready var task_id_count = NO_TASK_TASK_ID

func add_task(position, task_type: int) -> int:
	task_id_count += 1
	var new_task = Task.new().init(position, task_type, task_id_count)
	unassigned_tasks[task_id_count] = new_task
	return task_id_count

func _process(_delta):
	if unassigned_tasks.size() > 0 and ant_manager.are_there_idle_ants():
		var idle_ant_id = ant_manager.get_random_idle_ant_id()
		var random_task_id_to_assign =  unassigned_tasks.keys()[randi() % unassigned_tasks.size()]
		ant_manager.assign_task_to_ant(idle_ant_id, unassigned_tasks[random_task_id_to_assign])
		unassigned_tasks.erase(random_task_id_to_assign)

func get_no_task_task() -> Task:
	return no_task_task
