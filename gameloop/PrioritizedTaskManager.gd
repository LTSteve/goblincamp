extends Node

class_name PrioritizedTaskManager

static var _I: PrioritizedTaskManager

static var had_early_exit: bool = false

static var _high_priority: LinkedList = LinkedList.new()
static var _medium_priority: LinkedList = LinkedList.new()
static var _low_priority: LinkedList = LinkedList.new()

@export var minimum_medium_priority: int = 5
@export var minimum_low_priority: int = 1
@export var max_process_time_ms: int = 2
@export var tasks_per_check: int = 10

class PrioritizedTask:
	var done: bool = false
	var task: Callable
	var node: Node

func _ready():
	_I = self

static func add_high_priority_task(task:Callable, node:Node):
	var prioritized_task = PrioritizedTask.new()
	prioritized_task.task = task
	prioritized_task.node = node
	_high_priority.push(prioritized_task)
	return prioritized_task

static func add_medium_priority_task(task:Callable, node:Node):
	var prioritized_task = PrioritizedTask.new()
	prioritized_task.task = task
	prioritized_task.node = node
	_medium_priority.push(prioritized_task)
	return prioritized_task

static func add_low_priority_task(task:Callable, node:Node):
	var prioritized_task = PrioritizedTask.new()
	prioritized_task.task = task
	prioritized_task.node = node
	_low_priority.push(prioritized_task)
	return prioritized_task

func _process(_delta):
	# in ms
	var starting_time = Time.get_ticks_msec()
	var ending_time = starting_time+max_process_time_ms
	
	_run_through_n_tasks(_high_priority)
	_run_through_n_tasks(_medium_priority, minimum_medium_priority)
	_run_through_n_tasks(_low_priority, minimum_low_priority)
	
	_run_through_tasks_until(_medium_priority, ending_time)
	_run_through_tasks_until(_low_priority, ending_time)
	
	#var total_time = Time.get_ticks_msec() - starting_time
	#if total_time > max_process_time_ms:
	#	print("processed prioritized tasks for: ", total_time, "ms")

func _run_through_tasks_until(task_list:LinkedList, time):
	had_early_exit = false
	while true:
		if Time.get_ticks_msec() >= time:
			had_early_exit = true
			return
		for i in tasks_per_check:
			var task = task_list.pop()
			if task == null: return
			if is_instance_valid(task.node): task.task.call()
			task.done = true

func _run_through_n_tasks(task_list:LinkedList,n = -1):
	while n != 0:
		var task = task_list.pop()
		if task == null: return
		if is_instance_valid(task.node): task.task.call()
		task.done = true
		n -= 1
