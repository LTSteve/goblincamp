extends Resource

class_name InverseSignalBus

var callables: Array[Callable] = []

#clean up on scene load
func initialize():
	callables = []

func bind(callable:Callable):
	callables.append(callable)

func inverse_signal(type:int = -1) -> Array:
	var to_return := []
	
	for callable in callables:
		var ret = callable.call()
		if type != -1 && typeof(ret) != type:
			printerr("Type of ISB return was not as expected: Expected(%s), Got(%s)" % [type, typeof(ret)])
		to_return.append(ret)
	
	return to_return
