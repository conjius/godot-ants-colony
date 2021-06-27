class_name AntKinematicBody2D
extends KinematicBody2D

const ACCELERATION = 1000
const MAX_SPEED = 60
const FRICTION = 1000

onready var velocity = Vector2.ZERO

func walk(movement_vector : Vector2, delta: float):
	velocity = velocity.move_toward(movement_vector * MAX_SPEED, ACCELERATION * delta)
	velocity = move_and_slide(velocity)
	
func stop(delta: float):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
