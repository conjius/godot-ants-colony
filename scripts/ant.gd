extends Node2D

onready var queue = $"../PathingQueue"
onready var idle : bool = true
onready var target : Vector2 = Vector2.ZERO
onready var speed : float = 100

func _process(delta : float):
	if idle and queue.queue.size() > 0:
		target = queue.queue.pop_front()
		idle = false
	if not idle:
		move(position,target, delta*speed)
		

func move(from, to, by):
	var start_pos = position
	if abs((start_pos - target).length()) > by:
		position += (to - from).normalized() * by
		print(to, from)
	else: 
		idle = true
	
