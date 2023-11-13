extends CardModifier

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

func _exit_tree():
	#reset static values at end of session
	if card_resource.include_enemies:
		BurnEffect.crit_chance_enemies = 0
	if card_resource.include_players:
		BurnEffect.crit_chance_players = 0
