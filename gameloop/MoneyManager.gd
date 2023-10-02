extends Node

class_name MoneyManager

static var I:MoneyManager

@export var label: Label
@export var starting_money: int = 200

@export var debug: bool

var money: float:
	get:
		return money
	set(value):
		if value == money: return
		
		money = value
		label.text = "$%d" % money

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
