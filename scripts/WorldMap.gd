class_name WorldMap
extends Node2D

const TaskType = preload("res://scripts/common/TaskType.gd")

onready var terrain_tile_map = $MapNavigation2D/TerrainTileMap
onready var consumeable_tile_map = $MapNavigation2D/ConsumeableTileMap
onready var on_hover_tasks_tile_map = $MapNavigation2D/OnHoverTasksTileMap
onready var tasks_tile_map = $MapNavigation2D/TasksTileMap

func is_tile_interactable(tile_coordinates : Vector2):
	var is_consumeable_tile = consumeable_tile_map.get_used_cells().has(tile_coordinates)
	var terrain_tile_index = terrain_tile_map.get_cell_autotile_coord(tile_coordinates.x, tile_coordinates.y)
	return is_consumeable_tile or terrain_tile_index != Vector2.ZERO

func get_tile_task_type(tile_coordinates: Vector2):
	if consumeable_tile_map.get_used_cells().has(tile_coordinates):
		return TaskType.FORAGE
	if terrain_tile_map.get_cell_autotile_coord(tile_coordinates.x, tile_coordinates.y) != Vector2.ZERO:
		return TaskType.EXPLORE

func get_tile_root_world_position(world_position: Vector2) -> Vector2:
	var tile_coordinates = world_position_to_tile_coordinates(world_position)
	return tile_coordinates_to_world_position(tile_coordinates)
	
func world_position_to_tile_coordinates(world_position: Vector2):
	return terrain_tile_map.world_to_map(world_position)

func tile_coordinates_to_world_position(tile_coordinates: Vector2):
	return terrain_tile_map.map_to_world(tile_coordinates)

func are_two_positions_in_same_tile(position1: Vector2, position2: Vector2) -> bool:
	return world_position_to_tile_coordinates(position1) == world_position_to_tile_coordinates(position2)

func mark_on_hover_tile(tile_coordinates: Vector2):
	on_hover_tasks_tile_map.set_cellv(tile_coordinates, 0)

func unmark_on_hover_tile(tile_coordinates: Vector2):
	on_hover_tasks_tile_map.set_cellv(tile_coordinates, 2)

func mark_task_on_map(tile_coordinates: Vector2):
	tasks_tile_map.set_cellv(tile_coordinates, 0)
	
func unmark_task_on_map(tile_coordinates: Vector2):
	tasks_tile_map.set_cellv(tile_coordinates, 2)
