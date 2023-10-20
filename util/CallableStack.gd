class_name CallableStack

class Override:
	var id: String
	var priority: int = 0
	var callable: Callable
	func _init(p:int,c:Callable,i:String):
		priority = p
		callable = c
		id = i

var _base: Callable

var _cache_on_override: bool
var _cached_value

var override_stack:Array[Override]

func _init(base:Callable, cache_on_override: bool = false):
	_base = base
	_cache_on_override = cache_on_override
	if cache_on_override:
		_cached_value = base.callv([])

func execute(params:Array = []):
	if _cache_on_override: return _cached_value
	return _execute(params)

func _execute(params):
	var base_value = _base.callv(params)
	var current_value = base_value
	for override in override_stack:
		current_value = override.callable.callv([base_value, current_value])
	
	return current_value

## priority high = later in order
func add_override(id:Array, callable:Callable, priority: int = 0):
	var override = Override.new(priority, callable, UniqueMetaId.create(id))
	
	var inserted = false
	for i in override_stack.size():
		var o = override_stack[i]
		if o.priority >= priority:
			override_stack.insert(i, override)
			inserted = true
			break
	
	if !inserted:
		override_stack.append(override)
	
	if _cache_on_override:
		_cached_value = _execute([])

func remove_override(id: Array):
	var index = _first(UniqueMetaId.create(id))
	if index != -1:
		override_stack.remove_at(index)
	
	if _cache_on_override:
		_cached_value = _execute([])

func has_override(id:Array):
	var index = _first(UniqueMetaId.create(id))
	return index != -1

func _first(id:String):
	for i in override_stack.size():
		if override_stack[i].id == id:
			return i
	return -1
