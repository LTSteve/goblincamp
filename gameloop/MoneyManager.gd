extends Node

class_name MoneyManager

static var I:MoneyManager

signal on_change(new_value:int,old_value:int)

@export var label: Label
@export var starting_money: int = 200

@export var debug: bool

var money: float:
	get:
		return money
	set(value):
		if value == money: return
		if!(value == starting_money && money == 0):
			on_change.emit(value, money)
		money = value
		label.text = "%dg" % money

func _ready():
	I = self
	money += starting_money

func try_spend(amount: int) -> bool:
	if (money >= amount) || debug:
		money -= amount
		return true
	return false

func add_money(amount: int):
	money += amount
