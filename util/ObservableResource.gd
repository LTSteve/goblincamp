extends Resource

class_name ObservableResource

@export var default_value_ptr: Array

signal value_changed(current_value, old_value)

var _value

var value:
	get:
		return _value
	set(val):
		if val == _value: return
		var old_value = _value
		_value = val
		value_changed.emit(_value,old_value)

func initialize():
	_value = default_value_ptr[0]
