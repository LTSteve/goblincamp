extends Observable

class_name ObservableExpression

enum Operator {AND, OR, ADD, SUB, EQ}

@export var observable_1: Observable
@export var operator: Operator
@export var observable_2: Observable

var _value

func ready():
	observable_1.ready()
	observable_2.ready()
	
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
	var observable_1_value = observable_1.get_value()
	var observable_2_value = observable_2.get_value()
	match operator:
		Operator.AND:
			return observable_1_value && observable_2_value
		Operator.OR:
			return observable_1_value || observable_2_value
		Operator.ADD:
			return observable_1_value + observable_2_value
		Operator.SUB:
			return observable_1_value - observable_2_value
		Operator.EQ:
			return observable_1_value == observable_2_value
