class_name TodoList

var _tasks: LinkedList = LinkedList.new()

var _async: bool = false

var _remaining_steps: int

var _done: bool = false

signal done()

func _init(tasks:Array[Callable], async: bool = false):
	done.connect(func(): _done = true, CONNECT_ONE_SHOT)
	_async = async
	if async:
		_remaining_steps = tasks.size()
		for task in tasks:
			task.call(self)
	else:
		for task in tasks:
			_tasks.push(task)
		mark_step_done()
		

func mark_step_done():
	if _async:
		_remaining_steps -= 1
		if _remaining_steps == 0:
			done.emit()
	else:
		var task = _tasks.pop()
		if task: task.call(self)
		else: done.emit()

func finish_step_after_signal(signl: Signal):
	signl.connect(func(): mark_step_done(), CONNECT_ONE_SHOT)

func on_done(callback: Callable):
	if _done:
		callback.call()
	else:
		done.connect(callback, CONNECT_ONE_SHOT)
