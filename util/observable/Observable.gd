extends Resource

class_name Observable

signal value_changed(new_value, old_value)

var _is_ready: bool = false

func ready():
	_is_ready = true

func get_value():
	return null
