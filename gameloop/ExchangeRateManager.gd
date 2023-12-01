extends Node

class_name ExchangeRateManager

static var average_ear_exchange_rate: float

@export var min_exchange_rate: int = 50
@export var exchange_rate_range: int = 250
@export var random_component: int = 10
@export var max_phase_speed: float = 0.6
@export var min_phase_speed: float = 0.2
@export var phase_change_rate: float = 0.1

@export_group("Observables")
@export var is_day_resource: ObservableResource
@export var ear_exchange_rate_resource: ObservableResource

var _current_phase: float = 0
var _current_phase_change: float = 0.1

func _ready():
	average_ear_exchange_rate = int(min_exchange_rate + exchange_rate_range * 2.0)
	is_day_resource.value_changed.connect(_on_day_changed)

func on_sell(count:int):
	if MoneyManager.I.try_spend(count, MoneyManager.MoneyType.Ear):
		MoneyManager.I.add_money(count * ear_exchange_rate_resource.value, MoneyManager.MoneyType.Gold)
		return
	
	while MoneyManager.I.try_spend(1, MoneyManager.MoneyType.Ear):
		MoneyManager.I.add_money(ear_exchange_rate_resource.value, MoneyManager.MoneyType.Gold)

func on_buy(count:int):
	if MoneyManager.I.try_spend(count * ear_exchange_rate_resource.value, MoneyManager.MoneyType.Gold):
		MoneyManager.I.add_money(count, MoneyManager.MoneyType.Ear)

func _on_day_changed(is_day, _was_day):
	if !is_day: return
	#one time set since it's hidden on day 1
	_current_phase += _current_phase_change
	if _current_phase >= 1.0:
		_current_phase -= 1.0
	
	_current_phase_change = clampf(_current_phase_change + randf_range(-phase_change_rate, phase_change_rate), min_phase_speed, max_phase_speed)
	
	ear_exchange_rate_resource.value = min_exchange_rate + exchange_rate_range * Math.unit_sin(_current_phase) + randi_range(0, random_component)
