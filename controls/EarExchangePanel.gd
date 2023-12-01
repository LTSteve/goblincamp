extends Panel

class_name EarExchangePanel

@export var ear_exchange_rate_resource: ObservableResource

static var I: EarExchangePanel

func _ready():
	I = self

func on_sell(count:int):
	if MoneyManager.I.try_spend(count, MoneyManager.MoneyType.Ear):
		MoneyManager.I.add_money(count * ear_exchange_rate_resource.value, MoneyManager.MoneyType.Gold)
		return
	
	while MoneyManager.I.try_spend(1, MoneyManager.MoneyType.Ear):
		MoneyManager.I.add_money(ear_exchange_rate_resource.value, MoneyManager.MoneyType.Gold)

func on_buy(count:int):
	if MoneyManager.I.try_spend(count * ear_exchange_rate_resource.value, MoneyManager.MoneyType.Gold):
		MoneyManager.I.add_money(count, MoneyManager.MoneyType.Ear)
