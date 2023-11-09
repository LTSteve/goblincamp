extends Node

class_name MoneyManager

static var I:MoneyManager

signal on_change(new_value:int,old_value:int,type:MoneyType)

enum MoneyType {Gold=0,Ear,Hide,Iron,Dust}

@export var debug: bool

@export var resources: Array[int] = [200,0,0,0,0]
@export var labels: Array[Label] = []

func _ready():
	I = self
	for i in labels.size():
		labels[i].text = str(resources[i])

func try_spend(amount: int, type: MoneyType = MoneyType.Gold) -> bool:
	var current_money = resources[type]
	if (current_money >= amount) || debug:
		_change_amount(-amount, type)
		return true
	return false

func try_spend_multiple(amounts: Array[int], types: Array[MoneyType]) -> bool:
	var all_passed = true
	for i in types.size():
		var type = types[i]
		var amount = amounts[i]
		if resources[type] < amount:
			all_passed = false
			break
	
	if all_passed:
		for i in types.size():
			var type = types[i]
			var amount = amounts[i]
			_change_amount(-amount, type)
		return true
	return false

func add_money(amount: int, type: MoneyType = MoneyType.Gold):
	_change_amount(amount, type)

func _change_amount(amount: int, type: MoneyType):
	var old_value = resources[type]
	resources[type] += amount
	var new_value = resources[type]
	labels[type].text = str(new_value)
	on_change.emit(old_value, new_value, type)

func get_resource(type: MoneyType):
	return resources[type]
