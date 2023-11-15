extends CardModifier

func _initialize(_data):
	#activate the disenchantment menu
	DisenchantPanel.I.set_disenchant_properties(
		[params.days_needed_normal, params.days_needed_rare, params.days_needed_epic],
		[params.dust_normal, params.dust_rare, params.dust_epic])
	DisenchantPanel.I.add_disenchant_power(0)
	DB.I.observables.is_day.value_changed.connect(_on_day)
	
	OpenDisenchantButton.I.enable()

func _on_day(is_day, _was_day):
	if !is_day: return
	if current_rank <= 0: return
	DisenchantPanel.I.add_disenchant_power(current_rank)
