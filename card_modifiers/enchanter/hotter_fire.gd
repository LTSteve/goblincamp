extends CardModifier

func _apply(weapon:RangedWeapon,_unit):
	weapon.create_hit.add_override([weapon, self, "_create_hit_override"], _create_hit_override)

func _un_apply(weapon:RangedWeapon,_unit):
	weapon.create_hit.remove_override([weapon, self, "_create_hit_override"])

func _create_hit_override(base_value:Weapon.Hit, current_value:Weapon.Hit):
	current_value.damage += base_value.damage * params.damage_increase_percent * current_rank
	return current_value
