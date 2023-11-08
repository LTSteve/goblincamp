extends CardModifier

func _initialize(_data):
	#since we don't apply to units, we need to apply ourselves if we were added in the editor
	if current_rank != 0:
		_apply(null,null)

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
