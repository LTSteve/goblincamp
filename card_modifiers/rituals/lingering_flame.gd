extends CardModifier

func _apply(_null,_unit):
	if card_resource.include_enemies:
		BurnEffect.damage_scale_enemies = 1 + current_rank * params.add_scale_per_rank
	if card_resource.include_players:
		BurnEffect.damage_scale_players = 1 + current_rank * params.add_scale_per_rank

func _un_apply(_null,_unit):
	if card_resource.include_enemies:
		BurnEffect.damage_scale_enemies = 1
	if card_resource.include_players:
		BurnEffect.damage_scale_players = 1

func _exit_tree():
	#reset static values at end of session
	if card_resource.include_enemies:
		BurnEffect.damage_scale_enemies = 0
	if card_resource.include_players:
		BurnEffect.damage_scale_enemies = 0
