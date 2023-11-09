extends CardModifier

func _initialize(_data):
	GameManager.I.on_day.connect(_on_day)

func _on_day():
	if current_rank <= 0: return
	
	if !MoneyManager.I.try_spend(current_rank * params.cost_per_rank, MoneyManager.MoneyType.Gold): return
	
	MoneyManager.I.add_money(current_rank, MoneyManager.MoneyType.Iron)
