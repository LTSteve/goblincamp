extends Observable

class_name ObservableResource

@export var default_value_ptr: Array

var _value

var value:
	get:
		return _value
	set(val):
		if val == _value: return
		var old_value = _value
		_value = val
		value_changed.emit(_value,old_value)

func get_value():
	return _value

func initialize():
	_value = default_value_ptr[0]
	for connection in value_changed.get_connections():
		value_changed.disconnect(connection.callable)
