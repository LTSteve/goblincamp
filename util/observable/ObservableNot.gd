extends Observable

class_name ObservableNot

@export var sub_observable: Observable

var _value

func ready():
	if _is_ready: return
	sub_observable.ready()
	
	_value = _calc()
	sub_observable.value_changed.connect(_value_changed)
	super.ready()

func get_value():
	return _value

func _value_changed(_v, _ov):
	var old_value = _value
	_value = _calc()
	if _value != old_value:
		value_changed.emit(_value,old_value)

func _calc():
	return !sub_observable.get_value()
