extends Panel

class_name EarExchangePanel

@onready var exchange_rate_label: Label = $"MarginContainer2/HBoxContainer/Label2"

@export var min_exchange_rate: int = 50
@export var exchange_rate_range: int = 250
@export var random_component: int = 10
@export var max_phase_speed: float = 0.2
@export var min_phase_speed: float = 0.01
@export var phase_change_rate: float = 0.05

var _current_exchange_rate: int = 200

var _current_phase: float = 0
var _current_phase_change: float = 0.1

func on_sell(count:int):
	if MoneyManager.I.try_spend(count, MoneyManager.MoneyType.Ear):
		MoneyManager.I.add_money(count * _current_exchange_rate, MoneyManager.MoneyType.Gold)
		return
	
	while MoneyManager.I.try_spend(1, MoneyManager.MoneyType.Ear):
		MoneyManager.I.add_money(_current_exchange_rate, MoneyManager.MoneyType.Gold)

func on_buy(count:int):
	if MoneyManager.I.try_spend(count * _current_exchange_rate, MoneyManager.MoneyType.Gold):
		MoneyManager.I.add_money(count, MoneyManager.MoneyType.Ear)

func on_day():
	visible = true
	_current_phase += _current_phase_change
	if _current_phase >= 1.0:
		_current_phase -= 1.0
	
	_current_phase_change = clampf(_current_phase_change + randf_range(-phase_change_rate, phase_change_rate), min_phase_speed, max_phase_speed)
	
	_current_exchange_rate = min_exchange_rate + exchange_rate_range * Math.unit_sin(_current_phase) + randi_range(0, random_component)
	
	exchange_rate_label.text = str(_current_exchange_rate)
