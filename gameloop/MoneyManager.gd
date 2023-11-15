extends Node

class_name MoneyManager

static var I:MoneyManager

enum MoneyType {Gold=0,Ear,Hide,Iron,Dust}

@export var debug: bool

@export var resource_counts: Array[ObservableResource] = []

func _ready():
	I = self

func try_spend(amount: int, type: MoneyType = MoneyType.Gold) -> bool:
	var current_money = resource_counts[type].value
	if (current_money >= amount) || debug:
		_change_amount(-amount, type)
		return true
	return false

func try_spend_multiple(amounts: Array[int], types: Array[MoneyType]) -> bool:
	var all_passed = true
	for i in types.size():
		var type = types[i]
		var amount = amounts[i]
		if resource_counts[type].value < amount:
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
	resource_counts[type].value += amount

func get_resource(type: MoneyType):
	return resource_counts[type].value
