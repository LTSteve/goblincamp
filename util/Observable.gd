class_name Observable

signal value_changed(current_value, old_value)

var value:
	get:
		return value
	set(val):
		if val == value: return
		var old_value = value
		value = val
		value_changed.emit(value,old_value)
