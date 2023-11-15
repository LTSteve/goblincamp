extends Observable

class_name ObservableExpression

enum Operator {AND, OR}

@export var observable_1: Observable
@export var observable_1_match_value: Array
@export var operator: Operator
@export var observable_2: Observable
@export var observable_2_match_value: Array

var _value

func ready():
	_value = _calc()
	observable_1.value_changed.connect(_value_changed)
	observable_2.value_changed.connect(_value_changed)

func get_value():
	return _value

func _value_changed(_v, _ov):
	var old_value = _value
	_value = _calc()
	if _value != old_value:
		value_changed.emit(_value,old_value)

func _calc():
	var observable_1_match = observable_1.get_value() == observable_1_match_value[0]
	var observable_2_match = observable_2.get_value() == observable_2_match_value[0]
	if operator == Operator.AND:
		return observable_1_match && observable_2_match
	else:# operator == Operator.OR:
		return observable_1_match || observable_2_match
