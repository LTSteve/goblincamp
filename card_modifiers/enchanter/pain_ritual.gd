extends CardModifier

func _apply(weapon,_unit):
	weapon.damage_scale_x_100 += params.damage_increase_percent * current_rank

func _un_apply(weapon,_unit):
	weapon.damage_scale_x_100 -= params.damage_increase_percent * current_rank
