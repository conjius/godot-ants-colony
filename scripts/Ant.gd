extends Node2D
class_name Ant

const TaskType = preload("res://scripts/common/TaskType.gd")

enum AnimationState { IDLE, WALK }
const ANIMATION_STATE_NAMES = ["idle", "walk"]
enum MovementDirection {RIGHT, DOWN_RIGHT, DOWN, DOWN_LEFT, LEFT, UP_LEFT, UP, UP_RIGHT}
onready var MovementDirectionToUnitVector = {
	MovementDirection.RIGHT: Vector2(1, 0), 
	MovementDirection.DOWN_RIGHT: Vector2(1,1).normalized(), 
	MovementDirection.DOWN: Vector2(0, 1), 
	MovementDirection.DOWN_LEFT: Vector2(-1,1).normalized(), 
	MovementDirection.LEFT: Vector2(-1, 0), 
	MovementDirection.UP_LEFT: Vector2(-1, -1).normalized(), 
	MovementDirection.UP: Vector2(0, -1), 
	MovementDirection.UP_RIGHT: Vector2(1, -1).normalized()
}
const MOVEMENT_DIRECTION_NAMES = ["right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"]

onready var animated_sprite = $AntKinematicBody2D/AntAnimatedSprite
onready var kinematic_body_2d = $AntKinematicBody2D
onready var task_manager = $"/root/Root/TaskManager"
onready var ant_manager = $"/root/Root/AntManager"
onready var world_map = $"/root/Root/WorldMap"

onready var ant_id
onready var current_task : Task setget set_current_task, get_current_task 
onready var facing_direction = MovementDirection.DOWN

func init(new_ant_id: int, initial_task: Task, initial_position: Vector2) -> Ant:
	self.ant_id = new_ant_id
	self.current_task = initial_task
	self.position = initial_position
	return self

func _ready():
	animate(AnimationState.IDLE)

func animate(animation_state):
	facing_direction = direction_to_movement_direction(kinematic_body_2d.velocity)
	var frame_num = animated_sprite.frame
	animated_sprite.play(MOVEMENT_DIRECTION_NAMES[facing_direction] + "_" + ANIMATION_STATE_NAMES[animation_state])
	animated_sprite.frame = frame_num
  
func _process(delta):
	check_current_task_completion()
	var movement_vector = choose_movement_vector()
	if movement_vector == Vector2.ZERO:
		animate(AnimationState.IDLE)
		kinematic_body_2d.stop(delta)
	else:
		animate(AnimationState.WALK)
		kinematic_body_2d.walk(movement_vector, delta)

func check_current_task_completion():
	if is_current_task_completed():
		ant_manager.handle_task_completion(ant_id)

func is_current_task_completed() -> bool:
	match current_task.task_type:
		TaskType.NO_TASK: return false
		TaskType.EXPLORE: return world_map.are_two_positions_in_same_tile(kinematic_body_2d.position, current_task.position)
		_: return false

func choose_movement_vector():
	var movement_vector
	match current_task.get_task_type():
		TaskType.NO_TASK:
			var movement_direction = choose_random_direction() if should_change_direction() else facing_direction
			movement_vector = MovementDirectionToUnitVector[movement_direction]
		TaskType.EXPLORE:
			movement_vector = get_desired_movement_vector()
		_: print("Unsupported TaskType value for ant_id [%s]" % ant_id)
	# due to isometry, vertical movement is twice as slow
	movement_vector.y /= 2
	return movement_vector

func choose_random_direction():
	return MovementDirection.values()[randi() % MovementDirectionToUnitVector.size()]
	
func get_desired_movement_vector():
	var raw_direction: Vector2 = current_task.position - kinematic_body_2d.position
	return snap_to_8_way_dir(raw_direction)

func snap_to_8_way_dir(vector: Vector2) -> Vector2:
	var angle: float = fmod(vector.angle(), 2 * PI) # ignore complete turns around the origin
	var snapped_angle: float = stepify(angle, PI / 4) # snap to multiples of PI/4 radians (45 degrees)
	return Vector2.RIGHT.rotated(snapped_angle)

func should_change_direction():
	# adding multiples of an option increases its chance of being randomly selected
	var options = [
		true, 
		false, 
		false,
		false
	]
	return options[randi() % options.size()]

func direction_to_movement_direction(direction : Vector2):
	if direction == Vector2.ZERO:
		return facing_direction
	var angle = direction.angle()
	if angle < 0:
		angle += 2 * PI
	var index = int(round(angle / PI * 4)) % 8
	return index

func set_current_task(task: Task):
	current_task = task
	
func get_current_task() -> Task:
	return current_task
