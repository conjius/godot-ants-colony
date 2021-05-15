class_name AntManager
extends Node

onready var ant_scene = preload("res://scenes/Ant.tscn")

const NUM_ANTS_TO_SPAWN = 3
const ANT_SPAWN_MIN_X = 0
const ANT_SPAWN_MAX_X = 0
const ANT_SPAWN_MIN_Y = 0
const ANT_SPAWN_MAX_Y = 0

onready var task_manager = $"../TaskManager"
onready var world_map = $"../WorldMap"

onready var idle_ants = {}
onready var busy_ants = {}
onready var ant_id_counter = 0

func _ready():
	for i in NUM_ANTS_TO_SPAWN:
		spawn_ant()

func spawn_ant() -> void:
	ant_id_counter += 1
	var ant_initial_position = Vector2(rand_range(ANT_SPAWN_MIN_X, ANT_SPAWN_MAX_X), rand_range(ANT_SPAWN_MIN_Y, ANT_SPAWN_MAX_Y))
	var ant_instance = ant_scene.instance().init(ant_id_counter, task_manager.get_no_task_task(), ant_initial_position)
	add_child(ant_instance)
	idle_ants[ant_id_counter] = ant_instance

func are_there_idle_ants() -> bool: 
	return !idle_ants.empty()

func get_random_idle_ant_id() -> int:
	return idle_ants.keys()[randi() % idle_ants.size()]
	
func assign_task_to_ant(ant_id: int, task: Task):
	var ant: Ant = idle_ants[ant_id]
	ant.set_current_task(task)
	busy_ants[ant_id] = ant
	idle_ants.erase(ant_id)
	
func handle_task_completion(completing_ant_id: int):
	var completing_ant: Ant = busy_ants[completing_ant_id]
	var completed_task_tile_coordinates = world_map.world_position_to_tile_coordinates(completing_ant.get_current_task().position)
	busy_ants.erase(completing_ant_id)
	completing_ant.set_current_task(task_manager.get_no_task_task())
	idle_ants[completing_ant_id] = completing_ant
	world_map.unmark_task_on_map(completed_task_tile_coordinates)
