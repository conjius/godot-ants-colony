extends Node2D
class_name Ant

const TaskType = preload("res://scripts/common/TaskType.gd")

enum AnimationState { IDLE, WALK }
enum MovementDirection {RIGHT, DOWN_RIGHT, DOWN, DOWN_LEFT, LEFT, UP_LEFT, UP, UP_RIGHT, IDLE}

onready var movement_vectors = [
	Vector2(1, 0),					# right
	Vector2(1,1).normalized(),		# down right
	Vector2(0, 1),					# down
	Vector2(-1,1).normalized(),		# down left
	Vector2(-1, 0),					# left
	Vector2(-1, -1).normalized(),	# up left
	Vector2(0, -1),					# up
	Vector2(1, -1).normalized(),	# up right
	Vector2.ZERO,					# idle
]
onready var MovementDirectionToUnitVector = {
	MovementDirection.RIGHT: movement_vectors[0], 
	MovementDirection.DOWN_RIGHT: movement_vectors[1], 
	MovementDirection.DOWN: movement_vectors[2], 
	MovementDirection.DOWN_LEFT: movement_vectors[3], 
	MovementDirection.LEFT: movement_vectors[4], 
	MovementDirection.UP_LEFT: movement_vectors[5], 
	MovementDirection.UP: movement_vectors[6], 
	MovementDirection.UP_RIGHT: movement_vectors[7],
	MovementDirection.IDLE: movement_vectors[8],
}
const MOVEMENT_DIRECTION_NAMES = ["right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"]
const ANIMATION_STATE_NAMES = ["idle", "walk"]
const MIN_FRAMES_SINCE_LAST_DIRECTION_CHANGE = 60

onready var animated_sprite = $AntKinematicBody2D/AntAnimatedSprite
onready var kinematic_body_2d = $AntKinematicBody2D
onready var task_manager = $"/root/Root/TaskManager"
onready var ant_manager = $"/root/Root/AntManager"
onready var world_map = $"/root/Root/WorldMap"

onready var ant_id
onready var current_task : Task setget set_current_task, get_current_task 
onready var facing_direction = MovementDirection.DOWN
onready var frames_since_last_direction_change = 0

func init(new_ant_id: int, initial_task: Task, initial_position: Vector2) -> Ant:
	self.ant_id = new_ant_id
	self.current_task = initial_task
	self.position = initial_position
	return self

func _ready():
	animate(AnimationState.IDLE)

func animate(animation_state):
	var frame_num = animated_sprite.frame
	animated_sprite.play(MOVEMENT_DIRECTION_NAMES[facing_direction] + "_" + ANIMATION_STATE_NAMES[animation_state])
	animated_sprite.frame = frame_num
  
func _process(delta):
	check_current_task_completion()
	var movement_vector = update_movement_vector()
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

func update_movement_vector():
	var movement_vector
	match current_task.get_task_type():
		TaskType.NO_TASK:
			movement_vector = choose_random_movement_vector() if should_change_direction() else MovementDirectionToUnitVector[facing_direction]
		TaskType.EXPLORE:
			movement_vector = determine_explore_movement_vector() if should_change_direction() else MovementDirectionToUnitVector[facing_direction]
		_: print("Unsupported TaskType value for ant_id [%s]" % ant_id)
	facing_direction = snapped_movement_vector_to_movement_direction(movement_vector)
	# due to isometry, vertical movement is twice as slow
	movement_vector.y /= 2
	return movement_vector

func choose_random_movement_vector():
	var random_movement_direction = MovementDirection.values()[randi() % (MovementDirection.size() - 1)]
	return MovementDirectionToUnitVector[random_movement_direction]

func determine_explore_movement_vector() -> Vector2:
	var raw_direction: Vector2 = current_task.position - kinematic_body_2d.position
	var snapped_direction = snap_to_8_way_direction(raw_direction)
	return snapped_direction

func snapped_movement_vector_to_movement_direction(snapped_movement_vector: Vector2):
	var snapped_angle = normalize_vector_angle(snapped_movement_vector)
	var index = stepify(snapped_angle, PI / 4) / (PI / 4)
	return MovementDirection.values()[index]

func snap_to_8_way_direction(vector: Vector2) -> Vector2:
	var snapped_angle: float = stepify(normalize_vector_angle(vector), PI / 4) # snap to multiples of PI/4 radians (45 degrees)
	var snapped_vector = Vector2.RIGHT.rotated(snapped_angle)
	if abs(snapped_vector.x) == snapped_vector.x:
		snapped_vector.x = 0
	if abs(snapped_vector.y) == snapped_vector.y:
		snapped_vector.y = 0
	
	return snapped_vector

func normalize_vector_angle(vector: Vector2) -> float:
	var angle: float = fmod(vector.angle(), 2 * PI) # ignore complete turns around the origin
	if angle < 0:
		angle += 2 * PI		# treat negative angles as positive
	return angle

func should_change_direction():
	if frames_since_last_direction_change < MIN_FRAMES_SINCE_LAST_DIRECTION_CHANGE:
		frames_since_last_direction_change += 1
		return false

	var options = [
		true, 
		false,
		false,
		false
	]
	var should_change = options[randi() % options.size()]
	frames_since_last_direction_change = 0 if should_change else frames_since_last_direction_change + 1
	return should_change

func set_current_task(task: Task):
	current_task = task
	
func get_current_task() -> Task:
	return current_task
