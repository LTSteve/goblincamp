extends CardModifier

func _apply(weapon:MeleeWeapon,_unit:Unit):
	weapon.damage_scale_x_100 += 100 * current_rank

func _un_apply(weapon:MeleeWeapon,_unit:Unit):
	weapon.damage_scale_x_100 -= 100 * current_rank
