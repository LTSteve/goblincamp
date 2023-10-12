extends CardModifier

func _apply(weapon:RangedWeapon,_unit):
	weapon.damage_scale += 1 * current_rank

func _un_apply(weapon:RangedWeapon,_unit):
	weapon.damage_scale -= 1 * current_rank
