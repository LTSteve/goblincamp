extends CardModifier

func _initialize(_data):
	#since we don't apply to units, we need to apply ourselves if we were added in the editor
	if current_rank != 0:
		_apply(null,null)

func _apply(_null,_unit):
	if card_resource.include_enemies:
		BurnEffect.crit_chance_enemies = current_rank * params.crit_chance_per_rank
	if card_resource.include_players:
		BurnEffect.crit_chance_players = current_rank * params.crit_chance_per_rank

func _un_apply(_null,_unit):
	if card_resource.include_enemies:
		BurnEffect.crit_chance_enemies = 0
	if card_resource.include_players:
		BurnEffect.crit_chance_players = 0
