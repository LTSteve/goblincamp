extends CardModifier

func _initialize(_data):
	DB.I.observables.is_day.value_changed.connect(_on_day)

func _on_day(is_day, _was_day):
	if !is_day: return
	if current_rank <= 0: return
	
	for building in associated_buildings:
		if !MoneyManager.I.try_spend(params.cost_per_rank, MoneyManager.MoneyType.Gold): return
		building.send_resource(1, MoneyManager.MoneyType.Dust)

