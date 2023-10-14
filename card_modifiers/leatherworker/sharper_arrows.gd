extends CardModifier

func _apply(weapon:RangedWeapon,_unit):
	weapon.damage_scale_x_100 += params.damage_increase_percent * current_rank

func _un_apply(weapon:RangedWeapon,_unit):
	weapon.damage_scale_x_100 -= params.damage_increase_percent * current_rank
