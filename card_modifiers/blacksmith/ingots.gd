extends CardModifier

func _initialize(_data):
	DB.I.observables.is_day.value_changed.connect(_on_day)

func _on_day(is_day:bool, _was_day):
	if !is_day: return
	if current_rank <= 0: return
	
	if !MoneyManager.I.try_spend(current_rank * params.cost_per_rank, MoneyManager.MoneyType.Gold): return
	
	MoneyManager.I.add_money(current_rank, MoneyManager.MoneyType.Iron)
