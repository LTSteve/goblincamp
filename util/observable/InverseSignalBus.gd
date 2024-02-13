extends Resource

class_name InverseSignalBus

class OVP:
	var order:int
	var value:Callable
	
	func _init(v:Callable,o:int):
		order = o
		value = v

var callables: Array[OVP] = []

#clean up on scene load
func initialize():
	callables = []

func bind(callable:Callable, order: int = 0):
	var inserted := false
	var index := -1
	
	for ovp in callables:
		index += 1
		if ovp.order >= order:
			callables.insert(index, OVP.new(callable,order))
			inserted = true
			break
	
	if !inserted:
		callables.append(OVP.new(callable, order))

func inverse_signal() -> Array:
	var to_return := []
	
	for callable in callables:
		var ret = callable.value.call()
		to_return.append(ret)
	
	return to_return
