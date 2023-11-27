extends Node

class_name InverseSignal

var callables: Array[Callable] = []

func bind(callable:Callable):
	callables.append(callable)

func inverse_signal() -> Array:
	var to_return := []
	
	for callable in callables:
		var ret = callable.call()
		to_return.append(ret)
	
	return to_return
