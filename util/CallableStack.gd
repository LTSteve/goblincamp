class_name CallableStack

class Override:
	var priority: int = 0
	var callable: Callable
	func _init(p:int,c:Callable):
		priority = p
		callable = c

var _base: Callable

var override_stack:Array[Override]

func _init(base:Callable):
	_base = base

func execute(params:Array):
	var base_value = _base.callv(params)
	var current_value = base_value
	for override in override_stack:
		current_value = override.callable.callv([base_value, current_value])
	
	return current_value

## priority high = later in order
func add_override(callable:Callable, priority: int = 0) -> Override:
	var override = Override.new(priority, callable)
	
	var inserted = false
	for i in override_stack.size():
		var o = override_stack[i]
		if o.priority >= priority:
			override_stack.insert(i, override)
			inserted = true
			break
	
	if !inserted:
		override_stack.append(override)
	
	return override

func remove_override(override:Override):
	var index = override_stack.find(override)
	if index != -1:
		override_stack.remove_at(index)
